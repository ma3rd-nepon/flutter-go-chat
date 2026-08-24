package repository

import (
	"context"
	"fmt"
	"strings"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

func (r *ChatRepository) Search(ctx context.Context, userID uuid.UUID, q string, limit int) ([]domain.ChatView, error) {
	pattern := likePattern(strings.TrimSpace(q))

	rows, err := r.db.Query(ctx, `
		SELECT `+chatViewColumns+`
		FROM chats c
		JOIN chat_members cm
			ON cm.chat_id = c.id AND cm.user_id = $1
		WHERE c.title IS NOT NULL
		  AND c.title ILIKE $2 ESCAPE '\'
		ORDER BY c.created_at DESC
		LIMIT $3
	`, userID, pattern, limit)

	if err != nil {
		return nil, fmt.Errorf("search chats: %w", err)
	}

	defer rows.Close()

	items := make([]domain.ChatView, 0, limit)

	for rows.Next() {
		view, err := scanChatView(rows)
		if err != nil {
			return nil, err
		}

		items = append(items, *view)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("search chats rows error: %w", err)
	}

	return items, nil
}
