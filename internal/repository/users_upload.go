package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
)

func (r *UserRepository) SetAvatarURL(ctx context.Context, userID uuid.UUID, avatarURL string) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE users
		SET avatar_url = $2
		WHERE id = $1
	`, userID, avatarURL)

	if err != nil {
		return fmt.Errorf("set avatar url: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrUserNotFound
	}

	return nil
}

func (r *UserRepository) SetBannerURL(ctx context.Context, userID uuid.UUID, bannerURL string) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE users
		SET banner_url = $2
		WHERE id = $1
	`, userID, bannerURL)

	if err != nil {
		return fmt.Errorf("set banner url: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrUserNotFound
	}

	return nil
}
