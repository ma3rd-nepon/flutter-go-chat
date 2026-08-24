package handlers

import (
	"net/http"

	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
)

func (h *MessageHandler) Search(w http.ResponseWriter, r *http.Request) {
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

	q := r.URL.Query().Get("q")
	limit := parseLimit(r, 50, 100)

	messages, err := h.messages.Search(r.Context(), meID, chatID, q, limit)
	if err != nil {
		writeMessageError(w, r, err)
		return
	}

	items := h.buildResponses(r.Context(), meID, messages)

	response.OK(w, r, response.NewList(items, limit, nil, false))
}
