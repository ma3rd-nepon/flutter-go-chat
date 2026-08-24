package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"supernova/internal/domain"
)

var ErrInvalidPinTarget = errors.New("invalid pin target")

func (r *MessageRepository) PinMessage(ctx context.Context, chatID uuid.UUID, messageID uuid.UUID) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE chats
		SET pinned_message_id = $2
		WHERE id = $1
		  AND EXISTS (
			SELECT 1
			FROM messages
			WHERE id = $2 AND chat_id = $1
		  )
	`, chatID, messageID)

	if err != nil {
		return fmt.Errorf("pin message: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrInvalidPinTarget
	}

	return nil
}

func (r *MessageRepository) UnpinMessage(ctx context.Context, chatID uuid.UUID, messageID uuid.UUID) error {
	_, err := r.db.Exec(ctx, `
		UPDATE chats
		SET pinned_message_id = NULL
		WHERE id = $1
		  AND pinned_message_id = $2
	`, chatID, messageID)

	if err != nil {
		return fmt.Errorf("unpin message: %w", err)
	}

	return nil
}

func (r *MessageRepository) GetPinnedMessage(ctx context.Context, chatID uuid.UUID) (*domain.Message, error) {
	row := r.db.QueryRow(ctx, `
		SELECT `+messageColumns+`
		FROM messages
		WHERE chat_id = $1
		  AND id = (
			SELECT pinned_message_id
			FROM chats
			WHERE id = $1
		  )
	`, chatID)

	message, err := scanMessage(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}

		return nil, fmt.Errorf("get pinned message: %w", err)
	}

	return message, nil
}
