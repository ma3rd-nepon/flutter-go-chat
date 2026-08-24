package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type AddReactionRequest struct {
	Emoji string `json:"emoji"`
}

type ReactionResponse struct {
	ID        uuid.UUID         `json:"id"`
	MessageID uuid.UUID         `json:"message_id"`
	UserID    uuid.UUID         `json:"user_id"`
	Emoji     string            `json:"emoji"`
	CreatedAt unixtime.UnixTime `json:"created_at"`
}

func NewReactionResponse(reaction domain.Reaction) ReactionResponse {
	return ReactionResponse{
		ID:        reaction.ID,
		MessageID: reaction.MessageID,
		UserID:    reaction.UserID,
		Emoji:     reaction.Emoji,
		CreatedAt: unixtime.New(reaction.CreatedAt),
	}
}
