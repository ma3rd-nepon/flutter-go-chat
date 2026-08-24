package service

import (
	"context"
	"errors"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var ErrInvalidEmoji = errors.New("invalid emoji")

type ReactionService struct {
	reactions *repository.ReactionRepository
	messages  *repository.MessageRepository
	chats     *repository.ChatRepository
}

func NewReactionService(
	reactions *repository.ReactionRepository,
	messages *repository.MessageRepository,
	chats *repository.ChatRepository,
) *ReactionService {
	return &ReactionService{
		reactions: reactions,
		messages:  messages,
		chats:     chats,
	}
}

type ReactionResult struct {
	Reaction domain.Reaction
	ChatID   uuid.UUID
}

func (s *ReactionService) Add(ctx context.Context, messageID uuid.UUID, userID uuid.UUID, emoji string) (ReactionResult, bool, error) {
	message, err := s.messages.GetByID(ctx, messageID)
	if err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return ReactionResult{}, false, ErrMessageNotFound
		}

		return ReactionResult{}, false, err
	}

	if message.IsDeleted {
		return ReactionResult{}, false, ErrMessageNotFound
	}

	view, err := s.chats.GetChatView(ctx, message.ChatID, userID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return ReactionResult{}, false, ErrChatNotFound
		}

		return ReactionResult{}, false, err
	}

	if !view.IsMember {
		return ReactionResult{}, false, ErrChatNotFound
	}

	normalizedEmoji := strings.TrimSpace(emoji)

	if normalizedEmoji == "" || utf8.RuneCountInString(normalizedEmoji) > 32 {
		return ReactionResult{}, false, ErrInvalidEmoji
	}

	reaction := domain.Reaction{
		ID:        uuid.New(),
		MessageID: messageID,
		UserID:    userID,
		Emoji:     normalizedEmoji,
		CreatedAt: time.Now().UTC(),
	}

	added, err := s.reactions.Add(ctx, reaction)
	if err != nil {
		return ReactionResult{}, false, err
	}

	return ReactionResult{
		Reaction: reaction,
		ChatID:   message.ChatID,
	}, added, nil
}

func (s *ReactionService) Remove(ctx context.Context, messageID uuid.UUID, userID uuid.UUID, emoji string) (uuid.UUID, string, error) {
	message, err := s.messages.GetByID(ctx, messageID)
	if err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return uuid.Nil, "", ErrMessageNotFound
		}

		return uuid.Nil, "", err
	}

	if message.IsDeleted {
		return uuid.Nil, "", ErrMessageNotFound
	}

	view, err := s.chats.GetChatView(ctx, message.ChatID, userID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return uuid.Nil, "", ErrChatNotFound
		}

		return uuid.Nil, "", err
	}

	if !view.IsMember {
		return uuid.Nil, "", ErrChatNotFound
	}

	normalizedEmoji := strings.TrimSpace(emoji)

	if normalizedEmoji == "" || utf8.RuneCountInString(normalizedEmoji) > 32 {
		return uuid.Nil, "", ErrInvalidEmoji
	}

	if err := s.reactions.Remove(ctx, messageID, userID, normalizedEmoji); err != nil {
		return uuid.Nil, "", err
	}

	return message.ChatID, normalizedEmoji, nil
}
