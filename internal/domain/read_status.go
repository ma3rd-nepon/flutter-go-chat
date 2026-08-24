package domain

import (
	"github.com/google/uuid"
)

type ReadStatus struct {
	UserID            uuid.UUID
	LastReadMessageID *uuid.UUID
	Username          *string
	DisplayName       string
	AvatarURL         *string
}
