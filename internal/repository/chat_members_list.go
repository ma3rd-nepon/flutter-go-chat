package repository

import (
	"context"
	"fmt"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

func (r *ChatRepository) ListMembers(ctx context.Context, chatID uuid.UUID) ([]domain.ChatMemberView, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			u.id,
			u.username,
			u.display_name,
			u.avatar_url,
			u.status::text,
			u.last_seen,
			cm.role::text,
			cm.is_pinned,
			cm.muted_until,
			cm.restricted_until,
			cm.restricted_by,
			cm.restricted_reason,
			cm.joined_at
		FROM chat_members cm
		JOIN users u ON u.id = cm.user_id
		WHERE cm.chat_id = $1
		ORDER BY cm.joined_at
	`, chatID)

	if err != nil {
		return nil, fmt.Errorf("list chat members: %w", err)
	}

	defer rows.Close()

	members := make([]domain.ChatMemberView, 0, 64)

	for rows.Next() {
		var member domain.ChatMemberView
		var status string
		var role string

		if err := rows.Scan(
			&member.UserID,
			&member.Username,
			&member.DisplayName,
			&member.AvatarURL,
			&status,
			&member.LastSeen,
			&role,
			&member.IsPinned,
			&member.MutedUntil,
			&member.RestrictedUntil,
			&member.RestrictedBy,
			&member.RestrictedReason,
			&member.JoinedAt,
		); err != nil {
			return nil, fmt.Errorf("scan chat member: %w", err)
		}

		member.Status = domain.UserStatus(status)
		member.Role = domain.ChatMemberRole(role)

		members = append(members, member)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("chat members rows error: %w", err)
	}

	return members, nil
}

func (r *ChatRepository) GetCompanion(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (*domain.User, error) {
	row := r.db.QueryRow(ctx, `
		SELECT `+userColumns+`
		FROM users
		JOIN chat_members ON chat_members.user_id = users.id
		WHERE chat_members.chat_id = $1
		  AND chat_members.user_id <> $2
		LIMIT 1
	`, chatID, userID)

	user, err := scanUser(row)
	if err != nil {
		return nil, fmt.Errorf("get companion: %w", err)
	}

	return user, nil
}
