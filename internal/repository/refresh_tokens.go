package repository

import (
	"context"
	"errors"
	"fmt"
	"net"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"supernova/internal/domain"
)

var ErrRefreshTokenNotFound = errors.New("refresh token not found")

type RefreshTokenRepository struct {
	db *pgxpool.Pool
}

func NewRefreshTokenRepository(db *pgxpool.Pool) *RefreshTokenRepository {
	return &RefreshTokenRepository{db: db}
}

func cleanIP(ip *string) *string {
	if ip == nil {
		return nil
	}

	value := strings.TrimSpace(*ip)

	if value == "" {
		return nil
	}

	if host, _, err := net.SplitHostPort(value); err == nil {
		value = host
	}

	if net.ParseIP(value) == nil {
		return nil
	}

	return &value
}

func (r *RefreshTokenRepository) Create(ctx context.Context, token *domain.RefreshToken) error {
	if token.ID == uuid.Nil {
		token.ID = uuid.New()
	}

	if token.CreatedAt.IsZero() {
		token.CreatedAt = time.Now().UTC()
	}

	cleanedIP := cleanIP(token.IP)

	_, err := r.db.Exec(ctx, `
		INSERT INTO refresh_tokens (
			id,
			user_id,
			token_hash,
			user_agent,
			ip,
			expires_at,
			revoked_at,
			created_at
		) VALUES (
			$1, $2, $3, $4, $5::inet, $6, $7, $8
		)
	`,
		token.ID,
		token.UserID,
		token.TokenHash,
		token.UserAgent,
		cleanedIP,
		token.ExpiresAt,
		token.RevokedAt,
		token.CreatedAt,
	)

	if err != nil {
		return fmt.Errorf("create refresh token: %w", err)
	}

	return nil
}

func (r *RefreshTokenRepository) GetByHash(ctx context.Context, tokenHash string) (*domain.RefreshToken, error) {
	var token domain.RefreshToken

	err := r.db.QueryRow(ctx, `
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
		WHERE token_hash = $1
	`, tokenHash).Scan(
		&token.ID,
		&token.UserID,
		&token.TokenHash,
		&token.UserAgent,
		&token.IP,
		&token.ExpiresAt,
		&token.RevokedAt,
		&token.CreatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrRefreshTokenNotFound
		}

		return nil, fmt.Errorf("get refresh token: %w", err)
	}

	return &token, nil
}

func (r *RefreshTokenRepository) Revoke(ctx context.Context, tokenHash string) error {
	_, err := r.db.Exec(ctx, `
		UPDATE refresh_tokens
		SET revoked_at = now()
		WHERE token_hash = $1
		  AND revoked_at IS NULL
	`, tokenHash)

	if err != nil {
		return fmt.Errorf("revoke refresh token: %w", err)
	}

	return nil
}

func (r *RefreshTokenRepository) RevokeAllForUser(ctx context.Context, userID uuid.UUID) error {
	_, err := r.db.Exec(ctx, `
		UPDATE refresh_tokens
		SET revoked_at = now()
		WHERE user_id = $1
		  AND revoked_at IS NULL
	`, userID)

	if err != nil {
		return fmt.Errorf("revoke all refresh tokens: %w", err)
	}

	return nil
}
