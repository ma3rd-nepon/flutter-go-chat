package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type UserResponse struct {
	ID          uuid.UUID          `json:"id"`
	Email       string             `json:"email,omitempty"`
	Username    *string            `json:"username"`
	DisplayName string             `json:"display_name"`
	Bio         *string            `json:"bio"`
	AvatarURL   *string            `json:"avatar_url"`
	BannerURL   *string            `json:"banner_url"`
	Theme       *string            `json:"theme"`
	Status      domain.UserStatus  `json:"status"`
	Quote       *string            `json:"quote"`
	Music       *string            `json:"music"`
	LastSeen    *unixtime.UnixTime `json:"last_seen"`
	CreatedAt   unixtime.UnixTime  `json:"created_at"`
	UpdatedAt   unixtime.UnixTime  `json:"updated_at"`
}

func NewUserResponse(u *domain.User, includeEmail bool) UserResponse {
	resp := UserResponse{
		ID:          u.ID,
		Username:    u.Username,
		DisplayName: u.DisplayName,
		Bio:         u.Bio,
		AvatarURL:   u.AvatarURL,
		BannerURL:   u.BannerURL,
		Theme:       u.Theme,
		Status:      u.Status,
		Quote:       u.Quote,
		Music:       u.Music,
		LastSeen:    unixtime.NewPtr(u.LastSeen),
		CreatedAt:   unixtime.New(u.CreatedAt),
		UpdatedAt:   unixtime.New(u.UpdatedAt),
	}

	if includeEmail {
		resp.Email = u.Email
	}

	return resp
}

type AuthResponse struct {
	User            UserResponse `json:"user"`
	AccessToken     string       `json:"access_token"`
	RefreshToken    string       `json:"refresh_token"`
	TokenType       string       `json:"token_type"`
	ExpiresIn       int64        `json:"expires_in"`
	AccessExpiresAt int64        `json:"access_expires_at"`
}

type UpdateUserRequest struct {
	Username    *string `json:"username" validate:"omitempty,min=3,max=32"`
	DisplayName *string `json:"display_name" validate:"omitempty,min=1,max=64"`
	Bio         *string `json:"bio" validate:"omitempty,max=500"`
	Theme       *string `json:"theme" validate:"omitempty,max=64"`
	Status      *string `json:"status" validate:"omitempty,oneof=online offline invisible dnd"`
	Quote       *string `json:"quote" validate:"omitempty,max=160"`
	Music       *string `json:"music" validate:"omitempty,max=160"`
}
