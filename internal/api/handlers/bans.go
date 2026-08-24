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

type BanHandler struct {
	bans *service.BanService
}

func NewBanHandler(bans *service.BanService) *BanHandler {
	return &BanHandler{
		bans: bans,
	}
}

func (h *BanHandler) Ban(w http.ResponseWriter, r *http.Request) {
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

	var req dto.BanRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.UserID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "user_id is required")
		return
	}

	if err := h.bans.Ban(r.Context(), meID, chatID, req.UserID, req.Reason); err != nil {
		writeBanError(w, r, err)
		return
	}

	response.OK(w, r, map[string]any{
		"chat_id": chatID,
		"user_id": req.UserID,
		"banned":  true,
	})
}

func (h *BanHandler) Unban(w http.ResponseWriter, r *http.Request) {
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

	if err := h.bans.Unban(r.Context(), meID, chatID, userID); err != nil {
		writeBanError(w, r, err)
		return
	}

	response.OK(w, r, map[string]any{
		"chat_id": chatID,
		"user_id": userID,
		"banned":  false,
	})
}

func (h *BanHandler) List(w http.ResponseWriter, r *http.Request) {
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

	items, err := h.bans.List(r.Context(), meID, chatID)
	if err != nil {
		writeBanError(w, r, err)
		return
	}

	bans := make([]dto.BanViewResponse, 0, len(items))

	for _, item := range items {
		bans = append(bans, dto.NewBanViewResponse(item))
	}

	response.OK(w, r, response.NewList(bans, len(bans), nil, false))
}

func (h *BanHandler) AddMember(w http.ResponseWriter, r *http.Request) {
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

	var req struct {
		UserID uuid.UUID `json:"user_id"`
		Role   *string   `json:"role"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.UserID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "user_id is required")
		return
	}

	if err := h.bans.AddMember(r.Context(), meID, chatID, req.UserID, req.Role); err != nil {
		writeBanError(w, r, err)
		return
	}

	response.OK(w, r, map[string]any{
		"chat_id": chatID,
		"user_id": req.UserID,
		"added":   true,
	})
}

func writeBanError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, service.ErrMemberNotFound),
		errors.Is(err, service.ErrChatNotFound):
		response.NotFound(w, r, "not found")
		return

	case errors.Is(err, service.ErrCannotAddSelf),
		errors.Is(err, service.ErrInvalidRole):
		response.BadRequest(w, r, "validation_error", err.Error())
		return

	case errors.Is(err, service.ErrUserBanned),
		errors.Is(err, service.ErrNotAdmin),
		errors.Is(err, service.ErrNotOwner),
		errors.Is(err, service.ErrCannotModifyOwner),
		errors.Is(err, service.ErrForbidden):
		response.Forbidden(w, r, err.Error())
		return

	default:
		response.Internal(w, r)
		return
	}
}
