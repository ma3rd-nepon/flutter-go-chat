package service

import (
	"context"
	"errors"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

func (s *ReactionService) ListWithUsers(
	ctx context.Context,
	actorID uuid.UUID,
	messageID uuid.UUID,
) ([]domain.ReactionSummaryWithUsers, error) {
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

	rows, err := s.reactions.ListUsersByMessages(ctx, []uuid.UUID{messageID})
	if err != nil {
		return nil, err
	}

	return groupReactionRows(rows, actorID)[messageID], nil
}

func (s *ReactionService) SummariesByMessages(
	ctx context.Context,
	viewerID uuid.UUID,
	messageIDs []uuid.UUID,
) (map[uuid.UUID][]domain.ReactionSummaryWithUsers, error) {
	if len(messageIDs) == 0 {
		return map[uuid.UUID][]domain.ReactionSummaryWithUsers{}, nil
	}

	rows, err := s.reactions.ListUsersByMessages(ctx, messageIDs)
	if err != nil {
		return nil, err
	}

	return groupReactionRows(rows, viewerID), nil
}

func groupReactionRows(
	rows []domain.ReactionUserRow,
	viewerID uuid.UUID,
) map[uuid.UUID][]domain.ReactionSummaryWithUsers {
	type key struct {
		mid   uuid.UUID
		emoji string
	}

	result := make(map[uuid.UUID][]domain.ReactionSummaryWithUsers)
	index := make(map[key]int)

	for _, row := range rows {
		k := key{row.MessageID, row.Emoji}

		list := result[row.MessageID]

		pos, ok := index[k]
		if !ok {
			pos = len(list)
			list = append(list, domain.ReactionSummaryWithUsers{Emoji: row.Emoji})
			index[k] = pos
		}

		item := &list[pos]
		item.Count++

		if row.UserID == viewerID {
			item.ReactedByMe = true
		}

		item.Users = append(item.Users, domain.UserMini{
			ID:          row.UserID,
			Username:    row.Username,
			DisplayName: row.DisplayName,
			AvatarURL:   row.AvatarURL,
		})

		result[row.MessageID] = list
	}

	return result
}
