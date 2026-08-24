package handlers

import (
	"errors"
	"net/http"

	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/service"
)

type RoleHandler struct {
	roles *service.RoleService
}

func NewRoleHandler(roles *service.RoleService) *RoleHandler {
	return &RoleHandler{
		roles: roles,
	}
}

func (h *RoleHandler) SetAdmin(w http.ResponseWriter, r *http.Request) {
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

	if err := h.roles.SetAdmin(r.Context(), meID, chatID, userID); err != nil {
		writeRoleError(w, r, err)
		return
	}

	response.OK(w, r, map[string]any{
		"chat_id": chatID,
		"user_id": userID,
		"role":    "admin",
	})
}

func (h *RoleHandler) RemoveAdmin(w http.ResponseWriter, r *http.Request) {
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

	if err := h.roles.RemoveAdmin(r.Context(), meID, chatID, userID); err != nil {
		writeRoleError(w, r, err)
		return
	}

	response.OK(w, r, map[string]any{
		"chat_id": chatID,
		"user_id": userID,
		"role":    "member",
	})
}

func (h *RoleHandler) TransferOwner(w http.ResponseWriter, r *http.Request) {
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

	if err := h.roles.TransferOwner(r.Context(), meID, chatID, userID); err != nil {
		writeRoleError(w, r, err)
		return
	}

	response.OK(w, r, map[string]any{
		"chat_id": chatID,
		"owner":   userID,
	})
}

func (h *RoleHandler) Kick(w http.ResponseWriter, r *http.Request) {
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

	if err := h.roles.Kick(r.Context(), meID, chatID, userID); err != nil {
		writeRoleError(w, r, err)
		return
	}

	response.OK(w, r, map[string]any{
		"chat_id": chatID,
		"user_id": userID,
		"kicked":  true,
	})
}

func writeRoleError(w http.ResponseWriter, r *http.Request, err error) {
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
