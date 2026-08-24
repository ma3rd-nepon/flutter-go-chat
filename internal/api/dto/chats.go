package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type CreateChatRequest struct {
	Type        string      `json:"type"`
	Title       *string     `json:"title"`
	Description *string     `json:"description"`
	MemberIDs   []uuid.UUID `json:"member_ids"`
}

type UpdateChatRequest struct {
	Title       *string `json:"title"`
	Description *string `json:"description"`
	Theme       *string `json:"theme"`
}

type ChatResponse struct {
	ID                      uuid.UUID          `json:"id"`
	Type                    string             `json:"type"`
	Title                   *string            `json:"title"`
	Description             *string            `json:"description"`
	AvatarURL               *string            `json:"avatar_url"`
	Theme                   *string            `json:"theme"`
	OwnerID                 *uuid.UUID         `json:"owner_id"`
	PinnedMessageID         *uuid.UUID         `json:"pinned_message_id"`
	LastMessageID           *uuid.UUID         `json:"last_message_id"`
	LastMessageAt           *unixtime.UnixTime `json:"last_message_at"`
	AllowMemberInvite       bool               `json:"allow_member_invite"`
	AllowMemberEditInfo     bool               `json:"allow_member_edit_info"`
	AllowMemberSendMessages bool               `json:"allow_member_send_messages"`
	SlowModeSeconds         int                `json:"slow_mode_seconds"`
	MemberCount             int                `json:"member_count"`
	IsPinned                bool               `json:"is_pinned"`
	MyRole                  string             `json:"my_role"`
	UnreadCount             int                `json:"unread_count"`
	CreatedAt               unixtime.UnixTime  `json:"created_at"`
	UpdatedAt               unixtime.UnixTime  `json:"updated_at"`
}

func NewChatResponse(view domain.ChatView) ChatResponse {
	return ChatResponse{
		ID:                      view.Chat.ID,
		Type:                    string(view.Chat.Type),
		Title:                   view.Chat.Title,
		Description:             view.Chat.Description,
		AvatarURL:               view.Chat.AvatarURL,
		Theme:                   view.Chat.Theme,
		OwnerID:                 view.Chat.OwnerID,
		PinnedMessageID:         view.Chat.PinnedMessageID,
		LastMessageID:           view.Chat.LastMessageID,
		LastMessageAt:           unixtime.NewPtr(view.Chat.LastMessageAt),
		AllowMemberInvite:       view.Chat.AllowMemberInvite,
		AllowMemberEditInfo:     view.Chat.AllowMemberEditInfo,
		AllowMemberSendMessages: view.Chat.AllowMemberSendMessages,
		SlowModeSeconds:         view.Chat.SlowModeSeconds,
		MemberCount:             view.MemberCount,
		IsPinned:                view.IsPinned,
		MyRole:                  string(view.MyRole),
		UnreadCount:             view.UnreadCount,
		CreatedAt:               unixtime.New(view.Chat.CreatedAt),
		UpdatedAt:               unixtime.New(view.Chat.UpdatedAt),
	}
}
