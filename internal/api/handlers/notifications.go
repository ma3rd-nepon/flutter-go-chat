package handlers

import (
	"encoding/json"
	"net/http"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/service"
)

type NotificationHandler struct {
	notifications *service.NotificationService
}

func NewNotificationHandler(notifications *service.NotificationService) *NotificationHandler {
	return &NotificationHandler{
		notifications: notifications,
	}
}

func (h *NotificationHandler) List(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	limit := parseLimit(r, 20, 100)

	items, err := h.notifications.List(r.Context(), meID, limit)
	if err != nil {
		response.Internal(w, r)
		return
	}

	notifications := make([]dto.NotificationResponse, 0, len(items))

	for _, notification := range items {
		notifications = append(notifications, dto.NewNotificationResponse(notification))
	}

	response.OK(w, r, response.NewList(notifications, limit, nil, false))
}

func (h *NotificationHandler) Read(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.ReadNotificationsRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	count, err := h.notifications.Read(r.Context(), meID, req.NotificationIDs)
	if err != nil {
		response.Internal(w, r)
		return
	}

	response.OK(w, r, map[string]any{
		"read_count": count,
	})
}

func (h *NotificationHandler) ReadAll(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	count, err := h.notifications.ReadAll(r.Context(), meID)
	if err != nil {
		response.Internal(w, r)
		return
	}

	response.OK(w, r, map[string]any{
		"read_all":   true,
		"read_count": count,
	})
}
