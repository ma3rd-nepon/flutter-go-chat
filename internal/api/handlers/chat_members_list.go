package handlers

import (
	"errors"
	"net/http"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/service"
)

func (h *ChatHandler) ListMembers(w http.ResponseWriter, r *http.Request) {
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

	members, err := h.chats.ListMembers(r.Context(), meID, chatID)
	if err != nil {
		writeChatError(w, r, err)
		return
	}

	items := make([]dto.ChatMemberResponse, 0, len(members))

	for _, member := range members {
		items = append(items, dto.NewChatMemberResponse(member))
	}

	response.OK(w, r, response.NewList(items, len(items), nil, false))
}

func (h *ChatHandler) Companion(w http.ResponseWriter, r *http.Request) {
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

	user, err := h.chats.Companion(r.Context(), meID, chatID)
	if err != nil {
		if errors.Is(err, service.ErrCompanionNotAvailable) {
			response.BadRequest(w, r, "validation_error", err.Error())
			return
		}

		if errors.Is(err, service.ErrCompanionNotFound) {
			response.NotFound(w, r, "companion not found")
			return
		}

		writeChatError(w, r, err)
		return
	}

	response.OK(w, r, dto.NewUserResponse(user, false))
}
