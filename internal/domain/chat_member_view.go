package domain

import (
	"time"

	"github.com/google/uuid"
)

type ChatMemberView struct {
	UserID           uuid.UUID
	Username         *string
	DisplayName      string
	AvatarURL        *string
	Status           UserStatus
	LastSeen         *time.Time
	Role             ChatMemberRole
	IsPinned         bool
	MutedUntil       *time.Time
	JoinedAt         time.Time
	RestrictedUntil  *time.Time
	RestrictedBy     *uuid.UUID
	RestrictedReason *string
}
