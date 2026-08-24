package service

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"

	"supernova/internal/repository"
)

var muteForever = time.Date(9999, 12, 31, 23, 59, 59, 0, time.UTC)

type MuteService struct {
	chats *repository.ChatRepository
}

func NewMuteService(chats *repository.ChatRepository) *MuteService {
	return &MuteService{chats: chats}
}

func (s *MuteService) Mute(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, durationSeconds *int) error {
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

	mutedUntil := muteForever

	if durationSeconds != nil && *durationSeconds > 0 {
		mutedUntil = time.Now().UTC().Add(time.Duration(*durationSeconds) * time.Second)
	}

	return s.chats.SetMute(ctx, chatID, actorID, &mutedUntil)
}

func (s *MuteService) Unmute(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID) error {
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

	return s.chats.SetMute(ctx, chatID, actorID, nil)
}

func (s *MuteService) Status(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID) (bool, *time.Time, error) {
	view, err := s.chats.GetChatView(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return false, nil, ErrChatNotFound
		}

		return false, nil, err
	}

	if !view.IsMember {
		return false, nil, ErrChatNotFound
	}

	mutedUntil, err := s.chats.GetMuteUntil(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatMemberNotFound) {
			return false, nil, ErrChatNotFound
		}

		return false, nil, err
	}

	if mutedUntil == nil || mutedUntil.Before(time.Now().UTC()) {
		return false, nil, nil
	}

	if !mutedUntil.Before(muteForever) {
		return true, nil, nil
	}

	return true, mutedUntil, nil
}
