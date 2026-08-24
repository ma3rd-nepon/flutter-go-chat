package repository

import (
	"context"
	"fmt"
	"strings"

	"supernova/internal/domain"
)

func likePattern(q string) string {
	replacer := strings.NewReplacer(
		`\`, `\\`,
		`%`, `\%`,
		`_`, `\_`,
	)

	return "%" + replacer.Replace(q) + "%"
}

func (r *UserRepository) Search(ctx context.Context, q string, limit int) ([]domain.User, error) {
	pattern := likePattern(strings.ToLower(strings.TrimSpace(q)))

	rows, err := r.db.Query(ctx, `
		SELECT `+userColumns+`
		FROM users
		WHERE lower(COALESCE(username, '')) LIKE $1 ESCAPE '\'
		   OR lower(display_name) LIKE $1 ESCAPE '\'
		ORDER BY username
		LIMIT $2
	`, pattern, limit)

	if err != nil {
		return nil, fmt.Errorf("search users: %w", err)
	}

	defer rows.Close()

	users := make([]domain.User, 0, limit)

	for rows.Next() {
		user, err := scanUser(rows)
		if err != nil {
			return nil, err
		}

		users = append(users, *user)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("search users rows error: %w", err)
	}

	return users, nil
}
