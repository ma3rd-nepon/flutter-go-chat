package handlers

import (
	"net/http"

	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
)

func (h *MessageHandler) Pin(w http.ResponseWriter, r *http.Request) {
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

	messageID, err := uuidParam(r, "messageID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid message id")
		return
	}

	if err := h.messages.Pin(r.Context(), meID, chatID, messageID); err != nil {
		writeMessageError(w, r, err)
		return
	}

	response.OK(w, r, map[string]any{
		"pinned":     true,
		"message_id": messageID,
	})
}

func (h *MessageHandler) Unpin(w http.ResponseWriter, r *http.Request) {
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

	messageID, err := uuidParam(r, "messageID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid message id")
		return
	}

	if err := h.messages.Unpin(r.Context(), meID, chatID, messageID); err != nil {
		writeMessageError(w, r, err)
		return
	}

	response.OK(w, r, map[string]any{
		"pinned":     false,
		"message_id": messageID,
	})
}

func (h *MessageHandler) GetPinned(w http.ResponseWriter, r *http.Request) {
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

	message, err := h.messages.GetPinned(r.Context(), meID, chatID)
	if err != nil {
		writeMessageError(w, r, err)
		return
	}

	if message == nil {
		response.OK(w, r, map[string]any{
			"pinned_message": nil,
		})
		return
	}

	response.OK(w, r, map[string]any{
		"pinned_message": h.buildResponse(r.Context(), meID, *message),
	})
}
