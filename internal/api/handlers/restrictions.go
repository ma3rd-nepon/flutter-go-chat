package handlers

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"

	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/service"
	"supernova/internal/ws"
)

type RestrictionHandler struct {
	restrictions *service.RestrictionService
	events       *service.EventService
}

func NewRestrictionHandler(
	restrictions *service.RestrictionService,
	events *service.EventService,
) *RestrictionHandler {
	return &RestrictionHandler{
		restrictions: restrictions,
		events:       events,
	}
}

func (h *RestrictionHandler) Restrict(w http.ResponseWriter, r *http.Request) {
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

	userID, err := uuidParam(r, "userID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid user id")
		return
	}

	var req struct {
		DurationSeconds *int    `json:"duration_seconds"`
		Reason          *string `json:"reason"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil && !errors.Is(err, io.EOF) {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if err := h.restrictions.Restrict(r.Context(), meID, chatID, userID, req.DurationSeconds, req.Reason); err != nil {
		writeRestrictionError(w, r, err)
		return
	}

	chatIDCopy := chatID

	h.events.BroadcastChatEvent(
		r.Context(),
		chatIDCopy,
		nil,
		ws.NewEvent("member_restricted", &chatIDCopy, map[string]any{
			"user_id": userID,
			"by_id":   meID,
			"reason":  req.Reason,
		}),
	)

	response.OK(w, r, map[string]any{
		"chat_id":    chatID,
		"user_id":    userID,
		"restricted": true,
	})
}

func (h *RestrictionHandler) Unrestrict(w http.ResponseWriter, r *http.Request) {
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

	userID, err := uuidParam(r, "userID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid user id")
		return
	}

	if err := h.restrictions.Unrestrict(r.Context(), meID, chatID, userID); err != nil {
		writeRestrictionError(w, r, err)
		return
	}

	chatIDCopy := chatID

	h.events.BroadcastChatEvent(
		r.Context(),
		chatIDCopy,
		nil,
		ws.NewEvent("member_unrestricted", &chatIDCopy, map[string]any{
			"user_id": userID,
			"by_id":   meID,
		}),
	)

	response.OK(w, r, map[string]any{
		"chat_id":    chatID,
		"user_id":    userID,
		"restricted": false,
	})
}

func writeRestrictionError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, service.ErrMemberNotFound):
		response.NotFound(w, r, "member not found")
		return

	case errors.Is(err, service.ErrNotOwner),
		errors.Is(err, service.ErrNotAdmin),
		errors.Is(err, service.ErrCannotModifyOwner):
		response.Forbidden(w, r, err.Error())
		return

	default:
		response.Internal(w, r)
		return
	}
}
