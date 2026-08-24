package service

import (
	"context"
	"errors"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

func (s *MessageService) Pin(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, messageID uuid.UUID) error {
	view, err := s.chats.GetChatView(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return ErrChatNotFound
		}

		return err
	}

	if !view.IsMember {
		return ErrChatNotFound
	}

	err = s.messages.PinMessage(ctx, chatID, messageID)
	if err != nil {
		if errors.Is(err, repository.ErrInvalidPinTarget) {
			return ErrMessageNotFound
		}

		return err
	}

	return nil
}

func (s *MessageService) Unpin(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, messageID uuid.UUID) error {
	view, err := s.chats.GetChatView(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return ErrChatNotFound
		}

		return err
	}

	if !view.IsMember {
		return ErrChatNotFound
	}

	return s.messages.UnpinMessage(ctx, chatID, messageID)
}

func (s *MessageService) GetPinned(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID) (*domain.Message, error) {
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

	return s.messages.GetPinnedMessage(ctx, chatID)
}
