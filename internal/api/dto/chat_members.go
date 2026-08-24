package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type AddChatMemberRequest struct {
	UserID uuid.UUID `json:"user_id"`
	Role   *string   `json:"role"`
}

type AddChatMemberResponse struct {
	ChatID   uuid.UUID         `json:"chat_id"`
	UserID   uuid.UUID         `json:"user_id"`
	Role     string            `json:"role"`
	JoinedAt unixtime.UnixTime `json:"joined_at"`
}

type UpdateChatSettingsRequest struct {
	AllowMemberInvite       *bool `json:"allow_member_invite"`
	AllowMemberEditInfo     *bool `json:"allow_member_edit_info"`
	AllowMemberSendMessages *bool `json:"allow_member_send_messages"`
	SlowModeSeconds         *int  `json:"slow_mode_seconds"`
}

type PinResponse struct {
	ChatID   uuid.UUID `json:"chat_id"`
	IsPinned bool      `json:"is_pinned"`
}

func NewAddChatMemberResponse(member domain.ChatMember) AddChatMemberResponse {
	return AddChatMemberResponse{
		ChatID:   member.ChatID,
		UserID:   member.UserID,
		Role:     string(member.Role),
		JoinedAt: unixtime.New(member.JoinedAt),
	}
}
