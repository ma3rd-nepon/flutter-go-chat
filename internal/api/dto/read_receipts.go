package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
)

type ReadStatusResponse struct {
	UserID            uuid.UUID  `json:"user_id"`
	Username          *string    `json:"username"`
	DisplayName       string     `json:"display_name"`
	AvatarURL         *string    `json:"avatar_url"`
	LastReadMessageID *uuid.UUID `json:"last_read_message_id"`
}

type ReadByResponse struct {
	MessageID uuid.UUID   `json:"message_id"`
	ReadBy    []uuid.UUID `json:"read_by"`
}

func NewReadStatusResponse(item domain.ReadStatus) ReadStatusResponse {
	return ReadStatusResponse{
		UserID:            item.UserID,
		Username:          item.Username,
		DisplayName:       item.DisplayName,
		AvatarURL:         item.AvatarURL,
		LastReadMessageID: item.LastReadMessageID,
	}
}
