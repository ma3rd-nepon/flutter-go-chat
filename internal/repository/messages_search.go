package repository

import (
	"context"
	"fmt"
	"strings"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

func messageLikePattern(q string) string {
	replacer := strings.NewReplacer(
		`\`, `\\`,
		`%`, `\%`,
		`_`, `\_`,
	)

	return "%" + replacer.Replace(q) + "%"
}

func (r *MessageRepository) SearchInChat(ctx context.Context, chatID uuid.UUID, q string, limit int) ([]domain.Message, error) {
	pattern := messageLikePattern(strings.TrimSpace(q))

	rows, err := r.db.Query(ctx, `
		SELECT `+messageColumns+`
		FROM messages
		WHERE chat_id = $1
		  AND text ILIKE $2 ESCAPE '\'
		ORDER BY created_at DESC
		LIMIT $3
	`, chatID, pattern, limit)

	if err != nil {
		return nil, fmt.Errorf("search messages: %w", err)
	}

	defer rows.Close()

	items := make([]domain.Message, 0, limit)

	for rows.Next() {
		message, err := scanMessage(rows)
		if err != nil {
			return nil, err
		}

		items = append(items, *message)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("search messages rows error: %w", err)
	}

	return items, nil
}
