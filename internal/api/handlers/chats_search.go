package handlers

import (
	"net/http"
	"strings"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
)

func (h *ChatHandler) Search(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	q := strings.TrimSpace(r.URL.Query().Get("q"))
	limit := parseLimit(r, 20, 100)

	if q == "" {
		response.OK(w, r, response.NewList([]dto.ChatResponse{}, limit, nil, false))
		return
	}

	views, err := h.chats.Search(r.Context(), meID, q, limit)
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
