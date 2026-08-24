package service

import (
	"context"
	"errors"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var (
	ErrCompanionNotAvailable = errors.New("companion is available only for private chats")
	ErrCompanionNotFound     = errors.New("companion not found")
)

func (s *ChatService) ListMembers(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID) ([]domain.ChatMemberView, error) {
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

	return s.chats.ListMembers(ctx, chatID)
}

func (s *ChatService) Companion(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID) (*domain.User, error) {
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

	if view.Chat.Type != domain.ChatTypePrivate {
		return nil, ErrCompanionNotAvailable
	}

	user, err := s.chats.GetCompanion(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return nil, ErrCompanionNotFound
		}

		return nil, err
	}

	return user, nil
}
