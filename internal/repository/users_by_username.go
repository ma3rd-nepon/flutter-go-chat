package repository

import (
	"context"
	"fmt"

	"supernova/internal/domain"
)

func (r *UserRepository) GetByUsername(ctx context.Context, username string) (*domain.User, error) {
	row := r.db.QueryRow(ctx, `
		SELECT `+userColumns+`
		FROM users
		WHERE lower(username) = lower($1)
	`, username)

	user, err := scanUser(row)
	if err != nil {
		return nil, fmt.Errorf("get user by username: %w", err)
	}

	return user, nil
}
