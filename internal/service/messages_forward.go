package service

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

func (s *MessageService) Forward(ctx context.Context, actorID uuid.UUID, messageID uuid.UUID, targetChatID uuid.UUID) (domain.Message, error) {
	original, err := s.messages.GetByID(ctx, messageID)
	if err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return domain.Message{}, ErrMessageNotFound
		}

		return domain.Message{}, err
	}

	if original.IsDeleted {
		return domain.Message{}, ErrMessageNotFound
	}

	if original.Kind == domain.MessageKindSystem {
		return domain.Message{}, ErrInvalidMessageKind
	}

	originalView, err := s.chats.GetChatView(ctx, original.ChatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return domain.Message{}, ErrMessageNotFound
		}

		return domain.Message{}, err
	}

	if !originalView.IsMember {
		return domain.Message{}, ErrMessageNotFound
	}

	targetView, err := s.chats.GetChatView(ctx, targetChatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return domain.Message{}, ErrChatNotFound
		}

		return domain.Message{}, err
	}

	if !targetView.IsMember {
		return domain.Message{}, ErrChatNotFound
	}

	if !targetView.Chat.AllowMemberSendMessages &&
		targetView.MyRole != domain.ChatMemberRoleOwner &&
		targetView.MyRole != domain.ChatMemberRoleAdmin {
		return domain.Message{}, ErrForbidden
	}

	now := time.Now().UTC()

	forwarded := domain.Message{
		ID:              uuid.New(),
		ChatID:          targetChatID,
		SenderID:        &actorID,
		Kind:            original.Kind,
		Text:            original.Text,
		AttachmentURL:   original.AttachmentURL,
		ForwardedFromID: &original.ID,

		IsEdited:  false,
		IsDeleted: false,
		IsPinned:  false,

		CreatedAt: now,
		UpdatedAt: now,
	}

	if err := s.messages.Create(ctx, &forwarded); err != nil {
		return domain.Message{}, err
	}

	return forwarded, nil
}
