package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

func (r *UserRepository) GetByIDs(ctx context.Context, ids []uuid.UUID) (map[uuid.UUID]*domain.User, error) {
	result := make(map[uuid.UUID]*domain.User, len(ids))

	if len(ids) == 0 {
		return result, nil
	}

	rows, err := r.db.Query(ctx, `
		SELECT `+userColumns+`
		FROM users
		WHERE id = ANY($1::uuid[])
	`, ids)

	if err != nil {
		return nil, fmt.Errorf("get users by ids: %w", err)
	}

	defer rows.Close()

	for rows.Next() {
		user, err := scanUser(rows)
		if err != nil {
			return nil, err
		}

		result[user.ID] = user
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("users by ids rows error: %w", err)
	}

	return result, nil
}
