package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

func (r *MessageRepository) ReadBy(ctx context.Context, messageID uuid.UUID) ([]uuid.UUID, error) {
	rows, err := r.db.Query(ctx, `
		SELECT cm.user_id
		FROM chat_members cm
		JOIN messages target ON target.id = $1
		JOIN messages lr ON lr.id = cm.last_read_message_id
		WHERE cm.chat_id = target.chat_id
		  AND cm.user_id IS DISTINCT FROM target.sender_id
		  AND lr.created_at >= target.created_at
	`, messageID)

	if err != nil {
		return nil, fmt.Errorf("read by: %w", err)
	}

	defer rows.Close()

	userIDs := make([]uuid.UUID, 0, 64)

	for rows.Next() {
		var userID uuid.UUID

		if err := rows.Scan(&userID); err != nil {
			return nil, fmt.Errorf("scan read by: %w", err)
		}

		userIDs = append(userIDs, userID)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read by rows error: %w", err)
	}

	return userIDs, nil
}

func (r *ChatRepository) ReadStatus(ctx context.Context, chatID uuid.UUID) ([]domain.ReadStatus, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			cm.user_id,
			cm.last_read_message_id,
			u.username,
			u.display_name,
			u.avatar_url
		FROM chat_members cm
		JOIN users u ON u.id = cm.user_id
		WHERE cm.chat_id = $1
		ORDER BY cm.joined_at
	`, chatID)

	if err != nil {
		return nil, fmt.Errorf("read status: %w", err)
	}

	defer rows.Close()

	items := make([]domain.ReadStatus, 0, 64)

	for rows.Next() {
		var item domain.ReadStatus

		if err := rows.Scan(
			&item.UserID,
			&item.LastReadMessageID,
			&item.Username,
			&item.DisplayName,
			&item.AvatarURL,
		); err != nil {
			return nil, fmt.Errorf("scan read status: %w", err)
		}

		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read status rows error: %w", err)
	}

	return items, nil
}
