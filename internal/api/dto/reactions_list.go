package dto

import (
	"supernova/internal/domain"
)

type ReactionSummaryResponse struct {
	Emoji       string `json:"emoji"`
	Count       int    `json:"count"`
	ReactedByMe bool   `json:"reacted_by_me"`
}

func NewReactionSummaryResponse(item domain.ReactionSummary) ReactionSummaryResponse {
	return ReactionSummaryResponse{
		Emoji:       item.Emoji,
		Count:       item.Count,
		ReactedByMe: item.ReactedByMe,
	}
}
