package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
)

func (r *FriendRepository) ListFriendIDs(ctx context.Context, userID uuid.UUID) ([]uuid.UUID, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			CASE
				WHEN requester_id = $1 THEN addressee_id
				ELSE requester_id
			END AS friend_id
		FROM friends
		WHERE (requester_id = $1 OR addressee_id = $1)
		  AND status = 'accepted'
	`, userID)

	if err != nil {
		return nil, fmt.Errorf("list friend ids: %w", err)
	}

	defer rows.Close()

	friendIDs := make([]uuid.UUID, 0, 64)

	for rows.Next() {
		var friendID uuid.UUID

		if err := rows.Scan(&friendID); err != nil {
			return nil, fmt.Errorf("scan friend id: %w", err)
		}

		friendIDs = append(friendIDs, friendID)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("friend ids rows error: %w", err)
	}

	return friendIDs, nil
}
