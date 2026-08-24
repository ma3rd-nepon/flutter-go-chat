package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"supernova/internal/domain"
)

type FriendRepository struct {
	db *pgxpool.Pool
}

func NewFriendRepository(db *pgxpool.Pool) *FriendRepository {
	return &FriendRepository{db: db}
}

func (r *FriendRepository) GetPair(ctx context.Context, userA uuid.UUID, userB uuid.UUID) (*domain.Friend, error) {
	row := r.db.QueryRow(ctx, `
		SELECT id, requester_id, addressee_id, status, created_at, updated_at
		FROM friends
		WHERE (requester_id = $1 AND addressee_id = $2)
		   OR (requester_id = $2 AND addressee_id = $1)
	`, userA, userB)

	var f domain.Friend
	var status string

	err := row.Scan(
		&f.ID,
		&f.RequesterID,
		&f.AddresseeID,
		&status,
		&f.CreatedAt,
		&f.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}

		return nil, fmt.Errorf("get friend pair: %w", err)
	}

	f.Status = domain.FriendStatus(status)

	return &f, nil
}

func (r *FriendRepository) Create(ctx context.Context, f *domain.Friend) error {
	if f.ID == uuid.Nil {
		f.ID = uuid.New()
	}

	now := time.Now().UTC()

	if f.CreatedAt.IsZero() {
		f.CreatedAt = now
	}

	f.UpdatedAt = now

	var status string

	err := r.db.QueryRow(ctx, `
		INSERT INTO friends (
			id, requester_id, addressee_id, status, created_at, updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6
		)
		ON CONFLICT (requester_id, addressee_id)
		DO UPDATE SET
			status = EXCLUDED.status,
			updated_at = EXCLUDED.updated_at
		RETURNING id, requester_id, addressee_id, status, created_at, updated_at
	`,
		f.ID,
		f.RequesterID,
		f.AddresseeID,
		string(f.Status),
		f.CreatedAt,
		f.UpdatedAt,
	).Scan(
		&f.ID,
		&f.RequesterID,
		&f.AddresseeID,
		&status,
		&f.CreatedAt,
		&f.UpdatedAt,
	)

	if err != nil {
		return fmt.Errorf("create friend: %w", err)
	}

	f.Status = domain.FriendStatus(status)

	return nil
}

func (r *FriendRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status domain.FriendStatus) error {
	_, err := r.db.Exec(ctx, `
		UPDATE friends
		SET status = $2,
			updated_at = now()
		WHERE id = $1
	`, id, string(status))

	if err != nil {
		return fmt.Errorf("update friend status: %w", err)
	}

	return nil
}

func (r *FriendRepository) Delete(ctx context.Context, userA uuid.UUID, userB uuid.UUID) error {
	_, err := r.db.Exec(ctx, `
		DELETE FROM friends
		WHERE (requester_id = $1 AND addressee_id = $2)
		   OR (requester_id = $2 AND addressee_id = $1)
	`, userA, userB)

	if err != nil {
		return fmt.Errorf("delete friend: %w", err)
	}

	return nil
}

func (r *FriendRepository) ListFriends(ctx context.Context, userID uuid.UUID, limit int) ([]domain.FriendUser, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			f.id,
			CASE
				WHEN f.requester_id = $1 THEN f.addressee_id
				ELSE f.requester_id
			END AS other_user_id,
			u.username,
			u.display_name,
			u.avatar_url,
			f.status,
			f.created_at,
			f.updated_at
		FROM friends f
		JOIN users u ON u.id =
			CASE
				WHEN f.requester_id = $1 THEN f.addressee_id
				ELSE f.requester_id
			END
		WHERE (f.requester_id = $1 OR f.addressee_id = $1)
		  AND f.status = $2
		ORDER BY f.updated_at DESC
		LIMIT $3
	`, userID, string(domain.FriendStatusAccepted), limit)

	if err != nil {
		return nil, fmt.Errorf("list friends: %w", err)
	}

	return scanFriendUsers(rows, limit)
}

func (r *FriendRepository) ListRequests(ctx context.Context, userID uuid.UUID, direction string, limit int) ([]domain.FriendUser, error) {
	if direction == "outgoing" {
		rows, err := r.db.Query(ctx, `
			SELECT
				f.id,
				f.addressee_id,
				u.username,
				u.display_name,
				u.avatar_url,
				f.status,
				f.created_at,
				f.updated_at
			FROM friends f
			JOIN users u ON u.id = f.addressee_id
			WHERE f.requester_id = $1
			  AND f.status = $2
			ORDER BY f.created_at DESC
			LIMIT $3
		`, userID, string(domain.FriendStatusPending), limit)

		if err != nil {
			return nil, fmt.Errorf("list outgoing requests: %w", err)
		}

		return scanFriendUsers(rows, limit)
	}

	rows, err := r.db.Query(ctx, `
		SELECT
			f.id,
			f.requester_id,
			u.username,
			u.display_name,
			u.avatar_url,
			f.status,
			f.created_at,
			f.updated_at
		FROM friends f
		JOIN users u ON u.id = f.requester_id
		WHERE f.addressee_id = $1
		  AND f.status = $2
		ORDER BY f.created_at DESC
		LIMIT $3
	`, userID, string(domain.FriendStatusPending), limit)

	if err != nil {
		return nil, fmt.Errorf("list incoming requests: %w", err)
	}

	return scanFriendUsers(rows, limit)
}

func scanFriendUsers(rows pgx.Rows, limit int) ([]domain.FriendUser, error) {
	defer rows.Close()

	items := make([]domain.FriendUser, 0, limit)

	for rows.Next() {
		var item domain.FriendUser
		var status string

		if err := rows.Scan(
			&item.FriendID,
			&item.UserID,
			&item.Username,
			&item.DisplayName,
			&item.AvatarURL,
			&status,
			&item.CreatedAt,
			&item.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan friend user: %w", err)
		}

		item.Status = domain.FriendStatus(status)

		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("friend rows error: %w", err)
	}

	return items, nil
}
