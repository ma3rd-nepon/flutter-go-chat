package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type BanRequest struct {
	UserID uuid.UUID `json:"user_id"`
	Reason *string   `json:"reason"`
}

type BanViewResponse struct {
	UserID      uuid.UUID         `json:"user_id"`
	Username    *string           `json:"username"`
	DisplayName string            `json:"display_name"`
	AvatarURL   *string           `json:"avatar_url"`
	BannedBy    *uuid.UUID        `json:"banned_by"`
	Reason      *string           `json:"reason"`
	CreatedAt   unixtime.UnixTime `json:"created_at"`
}

func NewBanViewResponse(item domain.ChatBanView) BanViewResponse {
	return BanViewResponse{
		UserID:      item.UserID,
		Username:    item.Username,
		DisplayName: item.DisplayName,
		AvatarURL:   item.AvatarURL,
		BannedBy:    item.BannedBy,
		Reason:      item.Reason,
		CreatedAt:   unixtime.New(item.CreatedAt),
	}
}
