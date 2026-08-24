package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"

	"supernova/internal/domain"
)

type ChatBanRepository struct {
	db *pgxpool.Pool
}

func NewChatBanRepository(db *pgxpool.Pool) *ChatBanRepository {
	return &ChatBanRepository{db: db}
}

func (r *ChatBanRepository) Ban(ctx context.Context, ban domain.ChatBan) error {
	_, err := r.db.Exec(ctx, `
		INSERT INTO chat_bans (
			chat_id,
			user_id,
			banned_by,
			reason,
			created_at
		) VALUES (
			$1, $2, $3, $4, now()
		)
		ON CONFLICT (chat_id, user_id)
		DO UPDATE SET
			banned_by = EXCLUDED.banned_by,
			reason = EXCLUDED.reason,
			created_at = now()
	`, ban.ChatID, ban.UserID, ban.BannedBy, ban.Reason)

	if err != nil {
		return fmt.Errorf("ban user: %w", err)
	}

	return nil
}

func (r *ChatBanRepository) Unban(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) error {
	_, err := r.db.Exec(ctx, `
		DELETE FROM chat_bans
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID)

	if err != nil {
		return fmt.Errorf("unban user: %w", err)
	}

	return nil
}

func (r *ChatBanRepository) List(ctx context.Context, chatID uuid.UUID) ([]domain.ChatBanView, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			b.chat_id,
			b.user_id,
			u.username,
			u.display_name,
			u.avatar_url,
			b.banned_by,
			b.reason,
			b.created_at
		FROM chat_bans b
		JOIN users u ON u.id = b.user_id
		WHERE b.chat_id = $1
		ORDER BY b.created_at DESC
	`, chatID)

	if err != nil {
		return nil, fmt.Errorf("list bans: %w", err)
	}

	defer rows.Close()

	items := make([]domain.ChatBanView, 0, 64)

	for rows.Next() {
		var item domain.ChatBanView

		if err := rows.Scan(
			&item.ChatID,
			&item.UserID,
			&item.Username,
			&item.DisplayName,
			&item.AvatarURL,
			&item.BannedBy,
			&item.Reason,
			&item.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan ban: %w", err)
		}

		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("bans rows error: %w", err)
	}

	return items, nil
}

func (r *ChatBanRepository) IsBanned(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (bool, error) {
	var banned bool

	err := r.db.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1
			FROM chat_bans
			WHERE chat_id = $1 AND user_id = $2
		)
	`, chatID, userID).Scan(&banned)

	if err != nil {
		return false, fmt.Errorf("check ban: %w", err)
	}

	return banned, nil
}
