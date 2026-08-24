package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

var ErrRefreshSessionNotFound = errors.New("refresh session not found")

func (r *RefreshTokenRepository) ListActiveSessions(ctx context.Context, userID uuid.UUID) ([]domain.RefreshToken, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			id,
			user_id,
			token_hash,
			user_agent,
			host(ip)::text,
			expires_at,
			revoked_at,
			created_at
		FROM refresh_tokens
		WHERE user_id = $1
		  AND revoked_at IS NULL
		  AND expires_at > now()
		ORDER BY created_at DESC
	`, userID)

	if err != nil {
		return nil, fmt.Errorf("list active sessions: %w", err)
	}

	defer rows.Close()

	sessions := make([]domain.RefreshToken, 0, 32)

	for rows.Next() {
		var session domain.RefreshToken

		if err := rows.Scan(
			&session.ID,
			&session.UserID,
			&session.TokenHash,
			&session.UserAgent,
			&session.IP,
			&session.ExpiresAt,
			&session.RevokedAt,
			&session.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan active session: %w", err)
		}

		sessions = append(sessions, session)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("active sessions rows error: %w", err)
	}

	return sessions, nil
}

func (r *RefreshTokenRepository) RevokeByID(ctx context.Context, userID uuid.UUID, sessionID uuid.UUID) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE refresh_tokens
		SET revoked_at = now()
		WHERE id = $1
		  AND user_id = $2
		  AND revoked_at IS NULL
	`, sessionID, userID)

	if err != nil {
		return fmt.Errorf("revoke session by id: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrRefreshSessionNotFound
	}

	return nil
}
