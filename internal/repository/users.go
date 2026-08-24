package repository

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"supernova/internal/domain"
)

var (
	ErrUserNotFound  = errors.New("user not found")
	ErrEmailTaken    = errors.New("email already taken")
	ErrUsernameTaken = errors.New("username already taken")
)

type UserRepository struct {
	db *pgxpool.Pool
}

func NewUserRepository(db *pgxpool.Pool) *UserRepository {
	return &UserRepository{db: db}
}

const userColumns = `
	id,
	email,
	password_hash,
	username,
	display_name,
	bio,
	avatar_url,
	banner_url,
	theme,
	status,
	quote,
	music,
	last_seen,
	created_at,
	updated_at
`

func scanUser(row pgx.Row) (*domain.User, error) {
	var user domain.User
	var status string

	err := row.Scan(
		&user.ID,
		&user.Email,
		&user.PasswordHash,
		&user.Username,
		&user.DisplayName,
		&user.Bio,
		&user.AvatarURL,
		&user.BannerURL,
		&user.Theme,
		&status,
		&user.Quote,
		&user.Music,
		&user.LastSeen,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrUserNotFound
		}

		return nil, fmt.Errorf("scan user: %w", err)
	}

	user.Status = domain.UserStatus(status)

	return &user, nil
}

func (r *UserRepository) Create(ctx context.Context, user *domain.User) error {
	if user.ID == uuid.Nil {
		user.ID = uuid.New()
	}

	now := time.Now().UTC()

	if user.CreatedAt.IsZero() {
		user.CreatedAt = now
	}

	if user.UpdatedAt.IsZero() {
		user.UpdatedAt = now
	}

	if user.Status == "" {
		user.Status = domain.UserStatusOffline
	}

	_, err := r.db.Exec(ctx, `
		INSERT INTO users (
			id,
			email,
			password_hash,
			username,
			display_name,
			bio,
			avatar_url,
			banner_url,
			theme,
			status,
			quote,
			music,
			last_seen,
			created_at,
			updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15
		)
	`,
		user.ID,
		user.Email,
		user.PasswordHash,
		user.Username,
		user.DisplayName,
		user.Bio,
		user.AvatarURL,
		user.BannerURL,
		user.Theme,
		string(user.Status),
		user.Quote,
		user.Music,
		user.LastSeen,
		user.CreatedAt,
		user.UpdatedAt,
	)

	if err != nil {
		if isUniqueViolation(err, "users_email_lower_idx") {
			return ErrEmailTaken
		}

		if isUniqueViolation(err, "users_username_lower_idx") {
			return ErrUsernameTaken
		}

		return fmt.Errorf("create user: %w", err)
	}

	return nil
}

func (r *UserRepository) GetByEmail(ctx context.Context, email string) (*domain.User, error) {
	row := r.db.QueryRow(ctx, `
		SELECT `+userColumns+`
		FROM users
		WHERE lower(email) = lower($1)
	`, email)

	return scanUser(row)
}

func (r *UserRepository) GetByID(ctx context.Context, id string) (*domain.User, error) {
	row := r.db.QueryRow(ctx, `
		SELECT `+userColumns+`
		FROM users
		WHERE id = $1::uuid
	`, id)

	return scanUser(row)
}

func (r *UserRepository) Update(ctx context.Context, user *domain.User) error {
	_, err := r.db.Exec(ctx, `
		UPDATE users
		SET
			username = $2,
			display_name = $3,
			bio = $4,
			avatar_url = $5,
			banner_url = $6,
			theme = $7,
			status = $8,
			quote = $9,
			music = $10,
			last_seen = $11
		WHERE id = $1
	`,
		user.ID,
		user.Username,
		user.DisplayName,
		user.Bio,
		user.AvatarURL,
		user.BannerURL,
		user.Theme,
		string(user.Status),
		user.Quote,
		user.Music,
		user.LastSeen,
	)

	if err != nil {
		if isUniqueViolation(err, "users_username_lower_idx") {
			return ErrUsernameTaken
		}

		return fmt.Errorf("update user: %w", err)
	}

	return nil
}

func isUniqueViolation(err error, constraintName string) bool {
	if err == nil {
		return false
	}

	return strings.Contains(err.Error(), constraintName)
}
