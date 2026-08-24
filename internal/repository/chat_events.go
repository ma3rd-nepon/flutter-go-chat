package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
)

func (r *ChatRepository) ListMemberIDs(ctx context.Context, chatID uuid.UUID) ([]uuid.UUID, error) {
	rows, err := r.db.Query(ctx, `
		SELECT user_id
		FROM chat_members
		WHERE chat_id = $1
	`, chatID)

	if err != nil {
		return nil, fmt.Errorf("list chat member ids: %w", err)
	}

	defer rows.Close()

	userIDs := make([]uuid.UUID, 0, 32)

	for rows.Next() {
		var userID uuid.UUID

		if err := rows.Scan(&userID); err != nil {
			return nil, fmt.Errorf("scan chat member id: %w", err)
		}

		userIDs = append(userIDs, userID)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("chat member ids rows error: %w", err)
	}

	return userIDs, nil
}
