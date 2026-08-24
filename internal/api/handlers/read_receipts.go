package handlers

import (
	"net/http"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
)

func (h *MessageHandler) ReadBy(w http.ResponseWriter, r *http.Request) {
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

	userIDs, err := h.messages.ReadBy(r.Context(), meID, messageID)
	if err != nil {
		writeMessageError(w, r, err)
		return
	}

	response.OK(w, r, dto.ReadByResponse{
		MessageID: messageID,
		ReadBy:    userIDs,
	})
}

func (h *ChatHandler) ReadStatus(w http.ResponseWriter, r *http.Request) {
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

	items, err := h.chats.ReadStatus(r.Context(), meID, chatID)
	if err != nil {
		writeChatError(w, r, err)
		return
	}

	statuses := make([]dto.ReadStatusResponse, 0, len(items))

	for _, item := range items {
		statuses = append(statuses, dto.NewReadStatusResponse(item))
	}

	response.OK(w, r, response.NewList(statuses, len(statuses), nil, false))
}
