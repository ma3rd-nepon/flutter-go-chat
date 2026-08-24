package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

func (r *ReactionRepository) ListSummary(ctx context.Context, messageID uuid.UUID, viewerID uuid.UUID) ([]domain.ReactionSummary, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			r.emoji,
			count(*)::int AS count,
			EXISTS (
				SELECT 1
				FROM reactions r2
				WHERE r2.message_id = r.message_id
				  AND r2.emoji = r.emoji
				  AND r2.user_id = $2
			) AS reacted_by_me
		FROM reactions r
		WHERE r.message_id = $1
		GROUP BY r.message_id, r.emoji
		ORDER BY min(r.created_at)
	`, messageID, viewerID)

	if err != nil {
		return nil, fmt.Errorf("list reaction summary: %w", err)
	}

	defer rows.Close()

	items := make([]domain.ReactionSummary, 0, 32)

	for rows.Next() {
		var item domain.ReactionSummary

		if err := rows.Scan(
			&item.Emoji,
			&item.Count,
			&item.ReactedByMe,
		); err != nil {
			return nil, fmt.Errorf("scan reaction summary: %w", err)
		}

		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("reaction summary rows error: %w", err)
	}

	return items, nil
}
