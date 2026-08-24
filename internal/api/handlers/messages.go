package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/google/uuid"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/domain"
	"supernova/internal/repository"
	"supernova/internal/service"
	"supernova/internal/ws"
)

type MessageHandler struct {
	messages      *service.MessageService
	events        *service.EventService
	notifications *service.MessageNotificationService
	users         *repository.UserRepository
	reactions     *service.ReactionService
	attachments   *repository.AttachmentRepository
}

func NewMessageHandler(
	messages *service.MessageService,
	events *service.EventService,
	notifications *service.MessageNotificationService,
	users *repository.UserRepository,
	reactions *service.ReactionService,
	attachments *repository.AttachmentRepository,
) *MessageHandler {
	return &MessageHandler{
		messages:      messages,
		events:        events,
		notifications: notifications,
		users:         users,
		reactions:     reactions,
		attachments:   attachments,
	}
}

func (h *MessageHandler) buildResponses(
	ctx context.Context,
	viewerID uuid.UUID,
	items []domain.Message,
) []dto.MessageResponse {
	senderIDs := make([]uuid.UUID, 0, len(items))
	messageIDs := make([]uuid.UUID, 0, len(items))
	attachmentIDs := make([]uuid.UUID, 0, len(items))

	for _, m := range items {
		messageIDs = append(messageIDs, m.ID)
		if m.SenderID != nil {
			senderIDs = append(senderIDs, *m.SenderID)
		}
		if m.AttachmentID != nil {
			attachmentIDs = append(attachmentIDs, *m.AttachmentID)
		}
	}

	usersByID, err := h.users.GetByIDs(ctx, senderIDs)
	if err != nil {
		usersByID = map[uuid.UUID]*domain.User{}
	}

	reactionsByMessage, err := h.reactions.SummariesByMessages(ctx, viewerID, messageIDs)
	if err != nil {
		reactionsByMessage = map[uuid.UUID][]domain.ReactionSummaryWithUsers{}
	}

	attachmentsByID, err := h.attachments.GetByIDs(ctx, attachmentIDs)
	if err != nil {
		attachmentsByID = map[uuid.UUID]*domain.Attachment{}
	}

	out := make([]dto.MessageResponse, 0, len(items))

	for _, m := range items {
		var sender *dto.UserMiniResponse

		if m.SenderID != nil {
			if u, ok := usersByID[*m.SenderID]; ok {
				mini := dto.NewUserMiniResponse(domain.UserMini{
					ID:          u.ID,
					Username:    u.Username,
					DisplayName: u.DisplayName,
					AvatarURL:   u.AvatarURL,
				})
				sender = &mini
			}
		}

		reactions := make([]dto.ReactionSummaryWithUsersResponse, 0)
		for _, s := range reactionsByMessage[m.ID] {
			reactions = append(reactions, dto.NewReactionSummaryWithUsersResponse(s))
		}

		var attachment *dto.AttachmentResponse
		if m.AttachmentID != nil {
			if a, ok := attachmentsByID[*m.AttachmentID]; ok {
				att := dto.NewAttachmentResponse(*a)
				attachment = &att
			}
		}

		out = append(out, dto.NewMessageResponseWith(m, sender, reactions, attachment))
	}

	return out
}

func (h *MessageHandler) buildResponse(
	ctx context.Context,
	viewerID uuid.UUID,
	message domain.Message,
) dto.MessageResponse {
	return h.buildResponses(ctx, viewerID, []domain.Message{message})[0]
}

func (h *MessageHandler) List(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	chatID, err := uuidParam(r, "chatID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid chat id")
		return
	}

	limit := parseLimit(r, 50, 100)

	items, err := h.messages.List(r.Context(), chatID, meID, limit)
	if err != nil {
		writeMessageError(w, r, err)
		return
	}

	messages := h.buildResponses(r.Context(), meID, items)

	response.OK(w, r, response.NewList(messages, limit, nil, false))
}

func (h *MessageHandler) Create(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	chatID, err := uuidParam(r, "chatID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid chat id")
		return
	}

	var req dto.CreateMessageRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	input := service.CreateMessageInput{
		Text:          &req.Text,
		AttachmentID:  req.AttachmentID,
		AttachmentURL: req.AttachmentURL,
		Kind:          req.Kind,
		ReplyToID:     req.ReplyToID,
	}

	message, err := h.messages.Create(r.Context(), chatID, meID, input)
	if err != nil {
		writeMessageError(w, r, err)
		return
	}

	messageResponse := h.buildResponse(r.Context(), meID, message)
	messageChatID := message.ChatID

	h.events.BroadcastChatEvent(
		r.Context(),
		messageChatID,
		nil,
		ws.NewEvent(ws.EventNewMessage, &messageChatID, map[string]any{
			"message": messageResponse,
		}),
	)

	h.notifications.NotifyNewMessage(r.Context(), message)

	response.Created(w, r, messageResponse)
}

func (h *MessageHandler) Update(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	messageID, err := uuidParam(r, "messageID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid message id")
		return
	}

	var req dto.UpdateMessageRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	input := service.UpdateMessageInput{
		Text: &req.Text,
	}

	message, err := h.messages.Update(r.Context(), messageID, meID, input)
	if err != nil {
		writeMessageError(w, r, err)
		return
	}

	messageResponse := h.buildResponse(r.Context(), meID, message)
	messageChatID := message.ChatID

	h.events.BroadcastChatEvent(
		r.Context(),
		messageChatID,
		nil,
		ws.NewEvent(ws.EventMessageUpdated, &messageChatID, map[string]any{
			"message": messageResponse,
		}),
	)

	response.OK(w, r, messageResponse)
}

func (h *MessageHandler) Delete(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	messageID, err := uuidParam(r, "messageID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid message id")
		return
	}

	message, err := h.messages.Delete(r.Context(), messageID, meID)
	if err != nil {
		writeMessageError(w, r, err)
		return
	}

	messageResponse := h.buildResponse(r.Context(), meID, message)
	messageChatID := message.ChatID

	h.events.BroadcastChatEvent(
		r.Context(),
		messageChatID,
		nil,
		ws.NewEvent(ws.EventMessageDeleted, &messageChatID, map[string]any{
			"message": messageResponse,
		}),
	)

	response.OK(w, r, messageResponse)
}

func (h *MessageHandler) MarkRead(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	chatID, err := uuidParam(r, "chatID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid chat id")
		return
	}

	var req dto.MarkReadRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.LastMessageID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "last_message_id is required")
		return
	}

	if err := h.messages.MarkRead(r.Context(), chatID, meID, req.LastMessageID); err != nil {
		writeMessageError(w, r, err)
		return
	}

	chatIDCopy := chatID

	h.events.BroadcastChatEvent(
		r.Context(),
		chatIDCopy,
		nil,
		ws.NewEvent("messages_read", &chatIDCopy, map[string]any{
			"user_id":              meID,
			"last_read_message_id": req.LastMessageID,
		}),
	)

	response.OK(w, r, map[string]any{
		"chat_id":              chatID,
		"last_read_message_id": req.LastMessageID,
	})
}

func writeMessageError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, service.ErrEmptyMessage),
		errors.Is(err, service.ErrInvalidReply),
		errors.Is(err, service.ErrInvalidAttachment),
		errors.Is(err, service.ErrInvalidMessageKind):
		response.BadRequest(w, r, "validation_error", err.Error())
		return

	case errors.Is(err, service.ErrMessageNotFound),
		errors.Is(err, service.ErrChatNotFound):
		response.NotFound(w, r, "not found")
		return

	case errors.Is(err, service.ErrForbidden):
		response.Forbidden(w, r, "forbidden")
		return

	case errors.Is(err, service.ErrForbidden),
		errors.Is(err, service.ErrRestricted):
		response.Forbidden(w, r, err.Error())
		return

	default:
		response.Internal(w, r)
		return
	}
}
