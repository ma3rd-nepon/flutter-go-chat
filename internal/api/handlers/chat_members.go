package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/google/uuid"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/service"
	"supernova/internal/ws"
)

func (h *ChatHandler) AddMember(w http.ResponseWriter, r *http.Request) {
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

	var req dto.AddChatMemberRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.UserID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "user_id is required")
		return
	}

	member, added, err := h.chats.AddMember(r.Context(), chatID, meID, req.UserID, req.Role)
	if err != nil {
		writeChatError(w, r, err)
		return
	}

	memberResponse := dto.NewAddChatMemberResponse(member)

	if added {
		h.events.BroadcastChatEvent(
			r.Context(),
			chatID,
			nil,
			ws.NewEvent(ws.EventMemberAdded, &chatID, map[string]any{
				"member": memberResponse,
			}),
		)

		response.Created(w, r, memberResponse)
		return
	}

	response.OK(w, r, memberResponse)
}

func (h *ChatHandler) RemoveMember(w http.ResponseWriter, r *http.Request) {
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

	targetID, err := uuidParam(r, "userID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid user id")
		return
	}

	if err := h.chats.RemoveMember(r.Context(), chatID, meID, targetID); err != nil {
		writeChatError(w, r, err)
		return
	}

	h.events.BroadcastChatEvent(
		r.Context(),
		chatID,
		nil,
		ws.NewEvent(ws.EventMemberRemoved, &chatID, map[string]any{
			"user_id": targetID.String(),
		}),
	)

	response.OK(w, r, map[string]bool{
		"removed": true,
	})
}

func (h *ChatHandler) Pin(w http.ResponseWriter, r *http.Request) {
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

	if err := h.chats.SetPinned(r.Context(), chatID, meID, true); err != nil {
		writeChatError(w, r, err)
		return
	}

	response.OK(w, r, dto.PinResponse{
		ChatID:   chatID,
		IsPinned: true,
	})
}

func (h *ChatHandler) Unpin(w http.ResponseWriter, r *http.Request) {
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

	if err := h.chats.SetPinned(r.Context(), chatID, meID, false); err != nil {
		writeChatError(w, r, err)
		return
	}

	response.OK(w, r, dto.PinResponse{
		ChatID:   chatID,
		IsPinned: false,
	})
}

func (h *ChatHandler) UpdateSettings(w http.ResponseWriter, r *http.Request) {
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

	var req dto.UpdateChatSettingsRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	input := service.UpdateChatSettingsInput{
		AllowMemberInvite:       req.AllowMemberInvite,
		AllowMemberEditInfo:     req.AllowMemberEditInfo,
		AllowMemberSendMessages: req.AllowMemberSendMessages,
		SlowModeSeconds:         req.SlowModeSeconds,
	}

	view, err := h.chats.UpdateSettings(r.Context(), chatID, meID, input)
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
