package handlers

import (
	"encoding/json"
	"net/http"
	"supernova/internal/api/dto"
	"supernova/internal/api/response"
	"supernova/internal/pkg/validator"
	"supernova/internal/repository"
	"supernova/internal/service"

	"errors"
)

type AuthHandler struct {
	authService *service.AuthService
	validator   *validator.Validator
}

func NewAuthHandler(authService *service.AuthService, v *validator.Validator) *AuthHandler {
	return &AuthHandler{
		authService: authService,
		validator:   v,
	}
}

func (h *AuthHandler) Register(w http.ResponseWriter, r *http.Request) {
	var req dto.RegisterRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if fieldErrors := h.validator.Struct(req); fieldErrors != nil {
		details := make([]response.ErrorDetail, 0, len(fieldErrors))
		for _, fe := range fieldErrors {
			details = append(details, response.ErrorDetail{
				Field: fe.Field,
				Issue: fe.Issue,
			})
		}
		response.Fail(w, r, http.StatusBadRequest, "validation_error", "Request validation failed", details)
		return
	}

	result, err := h.authService.Register(r.Context(), req.Email, req.Password, req.DisplayName, req.Username)
	if err != nil {
		if errors.Is(err, repository.ErrEmailTaken) {
			response.Conflict(w, r, "email already taken")
			return
		}
		if errors.Is(err, repository.ErrUsernameTaken) {
			response.Conflict(w, r, "username already taken")
			return
		}
		response.Internal(w, r)
		return
	}

	authResp := dto.AuthResponse{
		User:            dto.NewUserResponse(result.User, true),
		AccessToken:     result.AccessToken,
		RefreshToken:    result.RefreshToken,
		TokenType:       "Bearer",
		ExpiresIn:       int64(result.ExpiresAt.Sub(result.User.CreatedAt).Seconds()),
		AccessExpiresAt: result.ExpiresAt.Unix(),
	}

	response.Created(w, r, authResp)
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req dto.LoginRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if fieldErrors := h.validator.Struct(req); fieldErrors != nil {
		details := make([]response.ErrorDetail, 0, len(fieldErrors))
		for _, fe := range fieldErrors {
			details = append(details, response.ErrorDetail{
				Field: fe.Field,
				Issue: fe.Issue,
			})
		}
		response.Fail(w, r, http.StatusBadRequest, "validation_error", "Request validation failed", details)
		return
	}

	result, err := h.authService.Login(r.Context(), req.Email, req.Password, r.UserAgent(), r.RemoteAddr)
	if err != nil {
		if errors.Is(err, service.ErrInvalidCredentials) {
			response.Fail(w, r, http.StatusUnauthorized, "invalid_credentials", "Invalid email or password", nil)
			return
		}
		response.Internal(w, r)
		return
	}

	authResp := dto.AuthResponse{
		User:            dto.NewUserResponse(result.User, true),
		AccessToken:     result.AccessToken,
		RefreshToken:    result.RefreshToken,
		TokenType:       "Bearer",
		ExpiresIn:       int64(result.ExpiresAt.Sub(result.User.CreatedAt).Seconds()),
		AccessExpiresAt: result.ExpiresAt.Unix(),
	}

	response.OK(w, r, authResp)
}

func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	var req dto.RefreshRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if fieldErrors := h.validator.Struct(req); fieldErrors != nil {
		details := make([]response.ErrorDetail, 0, len(fieldErrors))
		for _, fe := range fieldErrors {
			details = append(details, response.ErrorDetail{
				Field: fe.Field,
				Issue: fe.Issue,
			})
		}
		response.Fail(w, r, http.StatusBadRequest, "validation_error", "Request validation failed", details)
		return
	}

	result, err := h.authService.Refresh(r.Context(), req.RefreshToken, r.UserAgent(), r.RemoteAddr)
	if err != nil {
		if errors.Is(err, service.ErrTokenExpired) ||
			errors.Is(err, service.ErrTokenRevoked) ||
			errors.Is(err, service.ErrTokenInvalid) {
			response.Unauthorized(w, r, "invalid or expired refresh token")
			return
		}
		response.Internal(w, r)
		return
	}

	authResp := dto.AuthResponse{
		User:            dto.NewUserResponse(result.User, true),
		AccessToken:     result.AccessToken,
		RefreshToken:    result.RefreshToken,
		TokenType:       "Bearer",
		ExpiresIn:       int64(result.ExpiresAt.Sub(result.User.CreatedAt).Seconds()),
		AccessExpiresAt: result.ExpiresAt.Unix(),
	}

	response.OK(w, r, authResp)
}

func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
	var req dto.LogoutRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if err := h.authService.Logout(r.Context(), req.RefreshToken); err != nil {
		response.Internal(w, r)
		return
	}

	response.OK(w, r, map[string]bool{"revoked": true})
}
