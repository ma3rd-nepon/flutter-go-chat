package dto

import (
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type ChatMemberResponse struct {
	UserID           uuid.UUID          `json:"user_id"`
	Username         *string            `json:"username"`
	DisplayName      string             `json:"display_name"`
	AvatarURL        *string            `json:"avatar_url"`
	Status           string             `json:"status"`
	LastSeen         *unixtime.UnixTime `json:"last_seen"`
	Role             string             `json:"role"`
	IsPinned         bool               `json:"is_pinned"`
	Muted            bool               `json:"muted"`
	MutedUntil       *unixtime.UnixTime `json:"muted_until"`
	Restricted       bool               `json:"restricted"`
	RestrictedUntil  *unixtime.UnixTime `json:"restricted_until"`
	RestrictedBy     *uuid.UUID         `json:"restricted_by"`
	RestrictedReason *string            `json:"restricted_reason"`
	JoinedAt         unixtime.UnixTime  `json:"joined_at"`
}

func NewChatMemberResponse(member domain.ChatMemberView) ChatMemberResponse {
	now := time.Now()

	muted := member.MutedUntil != nil && member.MutedUntil.After(now)
	var mutedUntil *time.Time
	if muted && member.MutedUntil.Year() < 9999 {
		mutedUntil = member.MutedUntil
	}

	restricted := member.RestrictedUntil != nil && member.RestrictedUntil.After(now)
	var restrictedUntil *time.Time
	if restricted && member.RestrictedUntil.Year() < 9999 {
		restrictedUntil = member.RestrictedUntil
	}

	return ChatMemberResponse{
		UserID:           member.UserID,
		Username:         member.Username,
		DisplayName:      member.DisplayName,
		AvatarURL:        member.AvatarURL,
		Status:           string(member.Status),
		LastSeen:         unixtime.NewPtr(member.LastSeen),
		Role:             string(member.Role),
		IsPinned:         member.IsPinned,
		Muted:            muted,
		MutedUntil:       unixtime.NewPtr(mutedUntil),
		Restricted:       restricted,
		RestrictedUntil:  unixtime.NewPtr(restrictedUntil),
		RestrictedBy:     member.RestrictedBy,
		RestrictedReason: member.RestrictedReason,
		JoinedAt:         unixtime.New(member.JoinedAt),
	}
}
