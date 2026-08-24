package handlers

import (
	"net/http"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
)

func (h *ReactionHandler) List(w http.ResponseWriter, r *http.Request) {
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

	items, err := h.reactions.ListWithUsers(r.Context(), meID, messageID)
	if err != nil {
		writeReactionError(w, r, err)
		return
	}

	resp := make([]dto.ReactionSummaryWithUsersResponse, 0, len(items))

	for _, it := range items {
		resp = append(resp, dto.NewReactionSummaryWithUsersResponse(it))
	}

	response.OK(w, r, response.NewList(resp, len(resp), nil, false))
}
