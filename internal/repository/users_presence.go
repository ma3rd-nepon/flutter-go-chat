package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

func (r *UserRepository) SetPresence(
	ctx context.Context,
	userID uuid.UUID,
	status domain.UserStatus,
	lastSeen *time.Time,
) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE users
		SET
			status = $2,
			last_seen = $3
		WHERE id = $1
	`, userID, string(status), lastSeen)

	if err != nil {
		return fmt.Errorf("set presence: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrUserNotFound
	}

	return nil
}
