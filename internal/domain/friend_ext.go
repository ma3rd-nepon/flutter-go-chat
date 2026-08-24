package domain

import (
	"time"

	"github.com/google/uuid"
)

type FriendUser struct {
	FriendID    uuid.UUID
	UserID      uuid.UUID
	Username    *string
	DisplayName string
	AvatarURL   *string
	Status      FriendStatus
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
