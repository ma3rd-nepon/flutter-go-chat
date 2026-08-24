package handlers

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/domain"
	"supernova/internal/pkg/validator"
	"supernova/internal/repository"
)

type UserHandler struct {
	users     *repository.UserRepository
	validator *validator.Validator
}

func NewUserHandler(users *repository.UserRepository, v *validator.Validator) *UserHandler {
	return &UserHandler{
		users:     users,
		validator: v,
	}
}

func (h *UserHandler) Me(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	user, err := h.users.GetByID(r.Context(), meID.String())
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			response.NotFound(w, r, "user not found")
			return
		}

		response.Internal(w, r)
		return
	}

	response.OK(w, r, dto.NewUserResponse(user, true))
}

func (h *UserHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID := uuidParamString(r, "userID")

	user, err := h.users.GetByID(r.Context(), userID)
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			response.NotFound(w, r, "user not found")
			return
		}

		response.Internal(w, r)
		return
	}

	response.OK(w, r, dto.NewUserResponse(user, false))
}

func (h *UserHandler) UpdateMe(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.UpdateUserRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if fieldErrors := h.validator.Struct(req); fieldErrors != nil {
		details := make([]response.ErrorDetail, 0, len(fieldErrors))

		for _, fieldError := range fieldErrors {
			details = append(details, response.ErrorDetail{
				Field: fieldError.Field,
				Issue: fieldError.Issue,
			})
		}

		response.Fail(w, r, http.StatusBadRequest, "validation_error", "Request validation failed", details)
		return
	}

	user, err := h.users.GetByID(r.Context(), meID.String())
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			response.NotFound(w, r, "user not found")
			return
		}

		response.Internal(w, r)
		return
	}

	if req.Username != nil {
		user.Username = req.Username
	}

	if req.DisplayName != nil {
		user.DisplayName = *req.DisplayName
	}

	if req.Bio != nil {
		user.Bio = req.Bio
	}

	if req.Theme != nil {
		user.Theme = req.Theme
	}

	if req.Status != nil {
		user.Status = domain.UserStatus(*req.Status)
	}

	if req.Quote != nil {
		user.Quote = req.Quote
	}

	if req.Music != nil {
		user.Music = req.Music
	}

	if err := h.users.Update(r.Context(), user); err != nil {
		if errors.Is(err, repository.ErrUsernameTaken) {
			response.Conflict(w, r, "username already taken")
			return
		}

		response.Internal(w, r)
		return
	}

	response.OK(w, r, dto.NewUserResponse(user, true))
}

func (h *UserHandler) Search(w http.ResponseWriter, r *http.Request) {
	_, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	q := strings.TrimSpace(r.URL.Query().Get("q"))
	limit := parseLimit(r, 20, 100)

	if q == "" {
		response.OK(w, r, response.NewList([]dto.UserResponse{}, limit, nil, false))
		return
	}

	users, err := h.users.Search(r.Context(), q, limit)
	if err != nil {
		response.Internal(w, r)
		return
	}

	items := make([]dto.UserResponse, 0, len(users))

	for i := range users {
		items = append(items, dto.NewUserResponse(&users[i], false))
	}

	response.OK(w, r, response.NewList(items, limit, nil, false))
}

func uuidParamString(r *http.Request, key string) string {
	id, err := uuidParam(r, key)
	if err != nil {
		return ""
	}

	return id.String()
}
