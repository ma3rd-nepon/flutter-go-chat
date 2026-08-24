package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
)

type UserMiniResponse struct {
	ID          uuid.UUID `json:"id"`
	Username    *string   `json:"username"`
	DisplayName string    `json:"display_name"`
	AvatarURL   *string   `json:"avatar_url"`
}

type ReactionSummaryWithUsersResponse struct {
	Emoji       string             `json:"emoji"`
	Count       int                `json:"count"`
	ReactedByMe bool               `json:"reacted_by_me"`
	Users       []UserMiniResponse `json:"users"`
}

func NewUserMiniResponse(u domain.UserMini) UserMiniResponse {
	return UserMiniResponse{
		ID:          u.ID,
		Username:    u.Username,
		DisplayName: u.DisplayName,
		AvatarURL:   u.AvatarURL,
	}
}

func NewReactionSummaryWithUsersResponse(s domain.ReactionSummaryWithUsers) ReactionSummaryWithUsersResponse {
	users := make([]UserMiniResponse, 0, len(s.Users))

	for _, u := range s.Users {
		users = append(users, NewUserMiniResponse(u))
	}

	return ReactionSummaryWithUsersResponse{
		Emoji:       s.Emoji,
		Count:       s.Count,
		ReactedByMe: s.ReactedByMe,
		Users:       users,
	}
}
