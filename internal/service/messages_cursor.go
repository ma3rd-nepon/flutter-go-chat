package service

import (
	"context"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/cursor"
)

var ErrInvalidCursor = cursor.ErrInvalidCursor

func (s *MessageService) ListPage(
	ctx context.Context,
	chatID uuid.UUID,
	userID uuid.UUID,
	limit int,
	cursorRaw string,
) ([]domain.Message, *string, error) {
	view, err := s.chats.GetChatView(ctx, chatID, userID)
	if err != nil {
		return nil, nil, err
	}

	if !view.IsMember {
		return nil, nil, ErrChatNotFound
	}

	cur, err := cursor.Decode(cursorRaw)
	if err != nil {
		return nil, nil, ErrInvalidCursor
	}

	items, err := s.messages.ListByChatPage(ctx, chatID, limit, cur)
	if err != nil {
		return nil, nil, err
	}

	if len(items) > limit {
		items = items[:limit]

		last := items[len(items)-1]
		nextCursor := cursor.Encode(last.CreatedAt, last.ID)

		return items, &nextCursor, nil
	}

	return items, nil, nil
}
