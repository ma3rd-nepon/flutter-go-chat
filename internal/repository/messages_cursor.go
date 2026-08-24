package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/cursor"
)

func (r *MessageRepository) ListByChatPage(
	ctx context.Context,
	chatID uuid.UUID,
	limit int,
	cur *cursor.Cursor,
) ([]domain.Message, error) {
	var cursorTime *time.Time
	var cursorID uuid.UUID

	if cur != nil {
		cursorTime = &cur.Time
		cursorID = cur.ID
	}

	rows, err := r.db.Query(ctx, `
		SELECT `+messageColumns+`
		FROM messages m
		WHERE m.chat_id = $1
		  AND (
			$2::timestamptz IS NULL
			OR (m.created_at, m.id) < ($2::timestamptz, $3::uuid)
		  )
		ORDER BY m.created_at DESC, m.id DESC
		LIMIT $4
	`, chatID, cursorTime, cursorID, limit+1)

	if err != nil {
		return nil, fmt.Errorf("list messages page: %w", err)
	}

	defer rows.Close()

	items := make([]domain.Message, 0, limit+1)

	for rows.Next() {
		message, err := scanMessage(rows)
		if err != nil {
			return nil, err
		}

		items = append(items, *message)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("messages page rows error: %w", err)
	}

	return items, nil
}
