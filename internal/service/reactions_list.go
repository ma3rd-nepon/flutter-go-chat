package service

import (
	"context"
	"errors"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

func (s *ReactionService) ListSummary(ctx context.Context, actorID uuid.UUID, messageID uuid.UUID) ([]domain.ReactionSummary, error) {
	message, err := s.messages.GetByID(ctx, messageID)
	if err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return nil, ErrMessageNotFound
		}

		return nil, err
	}

	if message.IsDeleted {
		return nil, ErrMessageNotFound
	}

	view, err := s.chats.GetChatView(ctx, message.ChatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return nil, ErrChatNotFound
		}

		return nil, err
	}

	if !view.IsMember {
		return nil, ErrChatNotFound
	}

	return s.reactions.ListSummary(ctx, messageID, actorID)
}
