package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
)

func (r *ChatRepository) SetRestriction(
	ctx context.Context,
	chatID uuid.UUID,
	userID uuid.UUID,
	until *time.Time,
	byID *uuid.UUID,
	reason *string,
) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE chat_members
		SET restricted_until = $3,
		    restricted_by = $4,
		    restricted_reason = $5
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID, until, byID, reason)

	if err != nil {
		return fmt.Errorf("set chat restriction: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrChatMemberNotFound
	}

	return nil
}

func (r *ChatRepository) IsRestricted(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (bool, error) {
	var restricted bool

	err := r.db.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1
			FROM chat_members
			WHERE chat_id = $1
			  AND user_id = $2
			  AND restricted_until IS NOT NULL
			  AND restricted_until > now()
		)
	`, chatID, userID).Scan(&restricted)

	if err != nil {
		return false, fmt.Errorf("check chat restriction: %w", err)
	}

	return restricted, nil
}
