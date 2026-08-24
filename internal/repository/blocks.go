package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"supernova/internal/domain"
)

type BlockRepository struct {
	db *pgxpool.Pool
}

func NewBlockRepository(db *pgxpool.Pool) *BlockRepository {
	return &BlockRepository{db: db}
}

func (r *BlockRepository) Block(ctx context.Context, blockerID uuid.UUID, blockedID uuid.UUID, createdAt time.Time) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO blocks (blocker_id, blocked_id, created_at)
		VALUES ($1, $2, $3)
		ON CONFLICT (blocker_id, blocked_id) DO NOTHING
	`, blockerID, blockedID, createdAt)

	if err != nil {
		return fmt.Errorf("block user: %w", err)
	}

	return nil
}

func (r *BlockRepository) Unblock(ctx context.Context, blockerID uuid.UUID, blockedID uuid.UUID) error {
	_, err := r.db.Exec(ctx, `
		DELETE FROM blocks
		WHERE blocker_id = $1 AND blocked_id = $2
	`, blockerID, blockedID)

	if err != nil {
		return fmt.Errorf("unblock user: %w", err)
	}

	return nil
}

func (r *BlockRepository) List(ctx context.Context, blockerID uuid.UUID, limit int) ([]domain.BlockedUser, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			u.id,
			u.username,
			u.display_name,
			u.avatar_url,
			b.created_at
		FROM blocks b
		JOIN users u ON u.id = b.blocked_id
		WHERE b.blocker_id = $1
		ORDER BY b.created_at DESC
		LIMIT $2
	`, blockerID, limit)

	if err != nil {
		return nil, fmt.Errorf("list blocks: %w", err)
	}

	defer rows.Close()

	items := make([]domain.BlockedUser, 0, limit)

	for rows.Next() {
		var item domain.BlockedUser

		if err := rows.Scan(
			&item.UserID,
			&item.Username,
			&item.DisplayName,
			&item.AvatarURL,
			&item.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan blocked user: %w", err)
		}

		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows error: %w", err)
	}

	return items, nil
}
