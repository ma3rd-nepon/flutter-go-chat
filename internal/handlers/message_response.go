package handlers

import (
	"time"

	"github.com/google/uuid"
)

type UserBrief struct {
	ID          string  `json:"id"`
	Username    string  `json:"username"`
	DisplayName *string `json:"display_name"`
	AvatarURL   *string `json:"avatar_url"`
}

type ContentBlock struct {
	Type  string `json:"type"`
	Value string `json:"value,omitempty"`
	URL   string `json:"url,omitempty"`
	Name  string `json:"name,omitempty"`
}

type MessageResponse struct {
	ID        uuid.UUID      `json:"id"`
	ChatID    uuid.UUID      `json:"chat_id"`
	FromUser  UserBrief      `json:"from_user"`
	Content   []ContentBlock `json:"content"`
	ReplyTo   *ReplyInfo     `json:"reply_to,omitempty"`
	Status    string         `json:"status"`
	IsDeleted bool           `json:"is_deleted"`
	EditedAt  *time.Time     `json:"edited_at,omitempty"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
}
