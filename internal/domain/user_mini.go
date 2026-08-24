package domain

import (
	"time"

	"github.com/google/uuid"
)

type UserMini struct {
	ID          uuid.UUID
	Username    *string
	DisplayName string
	AvatarURL   *string
}

type ReactionUserRow struct {
	MessageID   uuid.UUID
	Emoji       string
	UserID      uuid.UUID
	Username    *string
	DisplayName string
	AvatarURL   *string
	CreatedAt   time.Time
}

type ReactionSummaryWithUsers struct {
	Emoji       string
	Count       int
	ReactedByMe bool
	Users       []UserMini
}
