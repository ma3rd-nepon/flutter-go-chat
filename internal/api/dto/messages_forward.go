package dto

import (
	"github.com/google/uuid"
)

type ForwardMessageRequest struct {
	ChatID uuid.UUID `json:"chat_id"`
}
