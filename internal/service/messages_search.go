package service

import (
	"context"
	"errors"
	"strings"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

func (s *MessageService) Search(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, q string, limit int) ([]domain.Message, error) {
	view, err := s.chats.GetChatView(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return nil, ErrChatNotFound
		}

		return nil, err
	}

	if !view.IsMember {
		return nil, ErrChatNotFound
	}

	if strings.TrimSpace(q) == "" {
		return []domain.Message{}, nil
	}

	return s.messages.SearchInChat(ctx, chatID, q, limit)
}
