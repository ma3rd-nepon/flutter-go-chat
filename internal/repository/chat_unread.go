package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
)

func (r *ChatRepository) UnreadCount(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (int, error) {
	var count int

	err := r.db.QueryRow(ctx, `
		SELECT count(*)
		FROM messages m
		WHERE m.chat_id = $1
		  AND m.is_deleted = false
		  AND m.sender_id IS DISTINCT FROM $2
		  AND EXISTS (
			SELECT 1
			FROM chat_members cm
			WHERE cm.chat_id = $1
			  AND cm.user_id = $2
			  AND (
				cm.last_read_message_id IS NULL
				OR m.created_at > (
					SELECT created_at
					FROM messages
					WHERE id = cm.last_read_message_id
				)
			  )
		  )
	`, chatID, userID).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("unread count: %w", err)
	}

	return count, nil
}
