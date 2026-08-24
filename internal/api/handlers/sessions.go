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

type SessionHandler struct {
	sessions *service.SessionService
}

func NewSessionHandler(sessions *service.SessionService) *SessionHandler {
	return &SessionHandler{
		sessions: sessions,
	}
}

func (h *SessionHandler) List(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	sessions, err := h.sessions.List(r.Context(), meID)
	if err != nil {
		response.Internal(w, r)
		return
	}

	items := make([]dto.SessionResponse, 0, len(sessions))

	for _, session := range sessions {
		items = append(items, dto.NewSessionResponse(session))
	}

	response.OK(w, r, response.NewList(items, len(items), nil, false))
}

func (h *SessionHandler) Revoke(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.RevokeSessionRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.SessionID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "session_id is required")
		return
	}

	if err := h.sessions.Revoke(r.Context(), meID, req.SessionID); err != nil {
		if errors.Is(err, service.ErrSessionNotFound) {
			response.NotFound(w, r, "session not found")
			return
		}

		response.Internal(w, r)
		return
	}

	response.OK(w, r, map[string]bool{
		"revoked": true,
	})
}
