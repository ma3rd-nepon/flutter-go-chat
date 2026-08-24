package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/domain"
	"supernova/internal/service"
	"supernova/internal/ws"
)

type ChatHandler struct {
	chats  *service.ChatService
	events *service.EventService
}

func NewChatHandler(chats *service.ChatService, events *service.EventService) *ChatHandler {
	return &ChatHandler{
		chats:  chats,
		events: events,
	}
}

func (h *ChatHandler) Create(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.CreateChatRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	req.Type = strings.ToLower(strings.TrimSpace(req.Type))

	switch req.Type {
	case "private", "group", "channel":
	default:
		response.BadRequest(w, r, "validation_error", "type must be private, group or channel")
		return
	}

	if req.Type == "private" {
		if len(req.MemberIDs) != 1 {
			response.BadRequest(w, r, "validation_error", "private chat requires exactly one member_id")
			return
		}
	} else {
		if req.Title == nil || strings.TrimSpace(*req.Title) == "" {
			response.BadRequest(w, r, "validation_error", "title is required")
			return
		}
	}

	input := service.CreateChatInput{
		Type:        domain.ChatType(req.Type),
		Title:       req.Title,
		Description: req.Description,
		MemberIDs:   req.MemberIDs,
	}

	view, created, err := h.chats.Create(r.Context(), meID, input)
	if err != nil {
		writeChatError(w, r, err)
		return
	}

	chatResponse := dto.NewChatResponse(view)

	if created {
		chatID := view.Chat.ID

		h.events.BroadcastChatEvent(
			r.Context(),
			chatID,
			nil,
			ws.NewEvent(ws.EventChatCreated, &chatID, map[string]any{
				"chat": chatResponse,
			}),
		)

		response.Created(w, r, chatResponse)
		return
	}

	response.OK(w, r, chatResponse)
}

func (h *ChatHandler) List(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	limit := parseLimit(r, 20, 100)

	views, err := h.chats.List(r.Context(), meID, limit)
	if err != nil {
		response.Internal(w, r)
		return
	}

	items := make([]dto.ChatResponse, 0, len(views))

	for _, view := range views {
		items = append(items, dto.NewChatResponse(view))
	}

	response.OK(w, r, response.NewList(items, limit, nil, false))
}

func (h *ChatHandler) Get(w http.ResponseWriter, r *http.Request) {
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

	view, err := h.chats.Get(r.Context(), chatID, meID)
	if err != nil {
		writeChatError(w, r, err)
		return
	}

	response.OK(w, r, dto.NewChatResponse(view))
}

func (h *ChatHandler) Update(w http.ResponseWriter, r *http.Request) {
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

	var req dto.UpdateChatRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	input := service.UpdateChatInput{
		Title:       req.Title,
		Description: req.Description,
		Theme:       req.Theme,
	}

	view, err := h.chats.Update(r.Context(), chatID, meID, input)
	if err != nil {
		writeChatError(w, r, err)
		return
	}

	chatResponse := dto.NewChatResponse(view)
	updatedChatID := view.Chat.ID

	h.events.BroadcastChatEvent(
		r.Context(),
		updatedChatID,
		nil,
		ws.NewEvent(ws.EventChatUpdated, &updatedChatID, map[string]any{
			"chat": chatResponse,
		}),
	)

	response.OK(w, r, chatResponse)
}

func (h *ChatHandler) Delete(w http.ResponseWriter, r *http.Request) {
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

	memberIDs, _ := h.events.MemberIDs(r.Context(), chatID)

	if err := h.chats.Delete(r.Context(), chatID, meID); err != nil {
		writeChatError(w, r, err)
		return
	}

	h.events.Broadcast(
		memberIDs,
		nil,
		ws.NewEvent(ws.EventChatDeleted, &chatID, map[string]any{
			"chat_id": chatID.String(),
		}),
	)

	response.OK(w, r, map[string]bool{
		"deleted": true,
	})
}

func uuidParam(r *http.Request, key string) (uuid.UUID, error) {
	raw := chi.URLParam(r, key)
	return uuid.Parse(raw)
}

func writeChatError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, service.ErrInvalidChatType),
		errors.Is(err, service.ErrTitleRequired),
		errors.Is(err, service.ErrInvalidMembers),
		errors.Is(err, service.ErrInvalidSettings):
		response.BadRequest(w, r, "validation_error", err.Error())
		return

	case errors.Is(err, service.ErrChatNotFound),
		errors.Is(err, service.ErrUserNotFound),
		errors.Is(err, service.ErrChatMemberNotFound):
		response.NotFound(w, r, "not found")
		return

	case errors.Is(err, service.ErrForbidden):
		response.Forbidden(w, r, "forbidden")
		return

	default:
		response.Internal(w, r)
		return
	}
}
