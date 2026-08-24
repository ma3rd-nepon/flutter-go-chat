package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/google/uuid"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/service"
)

func (h *MessageHandler) Forward(w http.ResponseWriter, r *http.Request) {
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

	var req dto.ForwardMessageRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.ChatID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "chat_id is required")
		return
	}

	message, err := h.messages.Forward(r.Context(), meID, messageID, req.ChatID)
	if err != nil {
		if errors.Is(err, service.ErrInvalidMessageKind) {
			response.BadRequest(w, r, "validation_error", err.Error())
			return
		}

		writeMessageError(w, r, err)
		return
	}

	response.Created(w, r, h.buildResponse(r.Context(), meID, message))
}
