package domain

import (
	"time"

	"github.com/google/uuid"
)

type Block struct {
	BlockerID uuid.UUID
	BlockedID uuid.UUID
	CreatedAt time.Time
}

type BlockedUser struct {
	UserID      uuid.UUID
	Username    *string
	DisplayName string
	AvatarURL   *string
	CreatedAt   time.Time
}
