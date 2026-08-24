package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
)

func (r *ChatRepository) SetAvatarURL(ctx context.Context, chatID uuid.UUID, avatarURL string) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE chats
		SET avatar_url = $2
		WHERE id = $1
	`, chatID, avatarURL)

	if err != nil {
		return fmt.Errorf("set chat avatar url: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrChatNotFound
	}

	return nil
}
