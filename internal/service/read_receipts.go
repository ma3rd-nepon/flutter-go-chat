package service

import (
	"context"
	"errors"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

func (s *MessageService) ReadBy(ctx context.Context, actorID uuid.UUID, messageID uuid.UUID) ([]uuid.UUID, error) {
	message, err := s.messages.GetByID(ctx, messageID)
	if err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return nil, ErrMessageNotFound
		}

		return nil, err
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

	return s.messages.ReadBy(ctx, messageID)
}

func (s *ChatService) ReadStatus(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID) ([]domain.ReadStatus, error) {
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

	return s.chats.ReadStatus(ctx, chatID)
}
