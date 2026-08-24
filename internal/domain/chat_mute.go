package domain

import (
	"time"

	"github.com/google/uuid"
)

type ChatMute struct {
	ChatID     uuid.UUID
	UserID     uuid.UUID
	MutedUntil *time.Time
	CreatedAt  time.Time
}
