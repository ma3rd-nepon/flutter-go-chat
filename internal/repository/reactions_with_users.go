package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

func (r *ReactionRepository) ListUsersByMessages(
	ctx context.Context,
	messageIDs []uuid.UUID,
) ([]domain.ReactionUserRow, error) {
	out := make([]domain.ReactionUserRow, 0)

	if len(messageIDs) == 0 {
		return out, nil
	}

	rows, err := r.db.Query(ctx, `
		SELECT
			r.message_id,
			r.emoji,
			u.id,
			u.username,
			u.display_name,
			u.avatar_url,
			r.created_at
		FROM reactions r
		JOIN users u ON u.id = r.user_id
		WHERE r.message_id = ANY($1::uuid[])
		ORDER BY r.message_id, r.emoji, r.created_at
	`, messageIDs)

	if err != nil {
		return nil, fmt.Errorf("list reaction users by messages: %w", err)
	}

	defer rows.Close()

	for rows.Next() {
		var row domain.ReactionUserRow

		if err := rows.Scan(
			&row.MessageID,
			&row.Emoji,
			&row.UserID,
			&row.Username,
			&row.DisplayName,
			&row.AvatarURL,
			&row.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan reaction user row: %w", err)
		}

		out = append(out, row)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("reaction users rows error: %w", err)
	}

	return out, nil
}
