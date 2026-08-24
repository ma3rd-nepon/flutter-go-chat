package repository

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"supernova/internal/domain"
)

type ReactionRepository struct {
	db *pgxpool.Pool
}

func NewReactionRepository(db *pgxpool.Pool) *ReactionRepository {
	return &ReactionRepository{db: db}
}

func (r *ReactionRepository) Add(ctx context.Context, reaction domain.Reaction) (bool, error) {
	if reaction.ID == uuid.Nil {
		reaction.ID = uuid.New()
	}

	if reaction.CreatedAt.IsZero() {
		reaction.CreatedAt = time.Now().UTC()
	}

	tag, err := r.db.Exec(ctx, `
		INSERT INTO reactions (
			id,
			message_id,
			user_id,
			emoji,
			created_at
		) VALUES (
			$1, $2, $3, $4, $5
		)
		ON CONFLICT (message_id, user_id, emoji) DO NOTHING
	`,
		reaction.ID,
		reaction.MessageID,
		reaction.UserID,
		reaction.Emoji,
		reaction.CreatedAt,
	)

	if err != nil {
		return false, fmt.Errorf("add reaction: %w", err)
	}

	return tag.RowsAffected() > 0, nil
}

func (r *ReactionRepository) Remove(ctx context.Context, messageID uuid.UUID, userID uuid.UUID, emoji string) error {
	_, err := r.db.Exec(ctx, `
		DELETE FROM reactions
		WHERE message_id = $1
		  AND user_id = $2
		  AND emoji = $3
	`, messageID, userID, emoji)

	if err != nil {
		return fmt.Errorf("remove reaction: %w", err)
	}

	return nil
}
