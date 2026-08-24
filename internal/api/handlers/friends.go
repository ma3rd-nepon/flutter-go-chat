package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/google/uuid"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/domain"
	"supernova/internal/service"
)

type FriendHandler struct {
	friends       *service.FriendService
	notifications *service.NotificationService
}

func NewFriendHandler(friends *service.FriendService, notifications *service.NotificationService) *FriendHandler {
	return &FriendHandler{
		friends:       friends,
		notifications: notifications,
	}
}

func (h *FriendHandler) Request(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.FriendUserRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.UserID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "user_id is required")
		return
	}

	friend, created, err := h.friends.Request(r.Context(), meID, req.UserID)
	if err != nil {
		writeFriendError(w, r, err)
		return
	}

	if friend.Status == domain.FriendStatusPending && created {
		h.notifications.NotifyFriendRequest(r.Context(), meID, friend.AddresseeID, friend.ID)
	}

	if friend.Status == domain.FriendStatusAccepted {
		h.notifications.NotifyFriendAccepted(r.Context(), meID, otherFriendUserID(friend, meID), friend.ID)
	}

	if created {
		response.Created(w, r, dto.NewFriendResponse(friend))
		return
	}

	response.OK(w, r, dto.NewFriendResponse(friend))
}

func (h *FriendHandler) Accept(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.FriendUserRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.UserID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "user_id is required")
		return
	}

	friend, err := h.friends.Accept(r.Context(), meID, req.UserID)
	if err != nil {
		writeFriendError(w, r, err)
		return
	}

	h.notifications.NotifyFriendAccepted(r.Context(), meID, otherFriendUserID(friend, meID), friend.ID)

	response.OK(w, r, dto.NewFriendResponse(friend))
}

func (h *FriendHandler) Reject(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.FriendUserRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.UserID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "user_id is required")
		return
	}

	friend, err := h.friends.Reject(r.Context(), meID, req.UserID)
	if err != nil {
		writeFriendError(w, r, err)
		return
	}

	response.OK(w, r, dto.NewFriendResponse(friend))
}

func (h *FriendHandler) Remove(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.FriendUserRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.UserID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "user_id is required")
		return
	}

	if err := h.friends.Remove(r.Context(), meID, req.UserID); err != nil {
		writeFriendError(w, r, err)
		return
	}

	response.OK(w, r, map[string]bool{
		"removed": true,
	})
}

func (h *FriendHandler) List(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	limit := parseLimit(r, 20, 100)

	items, err := h.friends.List(r.Context(), meID, limit)
	if err != nil {
		response.Internal(w, r)
		return
	}

	friends := make([]dto.FriendListItemResponse, 0, len(items))

	for _, item := range items {
		friends = append(friends, dto.NewFriendListItemResponse(item))
	}

	response.OK(w, r, response.NewList(friends, limit, nil, false))
}

func (h *FriendHandler) Requests(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	direction := r.URL.Query().Get("direction")
	if direction == "" {
		direction = "incoming"
	}

	if direction != "incoming" && direction != "outgoing" {
		response.BadRequest(w, r, "validation_error", "direction must be incoming or outgoing")
		return
	}

	limit := parseLimit(r, 20, 100)

	items, err := h.friends.Requests(r.Context(), meID, direction, limit)
	if err != nil {
		response.Internal(w, r)
		return
	}

	requests := make([]dto.FriendListItemResponse, 0, len(items))

	for _, item := range items {
		requests = append(requests, dto.NewFriendListItemResponse(item))
	}

	response.OK(w, r, response.NewList(requests, limit, nil, false))
}

func otherFriendUserID(friend domain.Friend, meID uuid.UUID) uuid.UUID {
	if friend.RequesterID == meID {
		return friend.AddresseeID
	}

	return friend.RequesterID
}

func writeFriendError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, service.ErrCannotFriendSelf):
		response.BadRequest(w, r, "validation_error", "cannot perform this action with yourself")
		return

	case errors.Is(err, service.ErrUserNotFound):
		response.NotFound(w, r, "user not found")
		return

	case errors.Is(err, service.ErrAlreadyFriends):
		response.Conflict(w, r, "already friends")
		return

	case errors.Is(err, service.ErrFriendRequestNotFound):
		response.NotFound(w, r, "friend request not found")
		return

	default:
		response.Internal(w, r)
		return
	}
}
