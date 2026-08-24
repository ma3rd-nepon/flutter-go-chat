package domain

import (
	"time"

	"github.com/google/uuid"
)

type ChatBan struct {
	ChatID    uuid.UUID
	UserID    uuid.UUID
	BannedBy  *uuid.UUID
	Reason    *string
	CreatedAt time.Time
}

type ChatBanView struct {
	ChatID      uuid.UUID
	UserID      uuid.UUID
	Username    *string
	DisplayName string
	AvatarURL   *string
	BannedBy    *uuid.UUID
	Reason      *string
	CreatedAt   time.Time
}
