package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"supernova/internal/domain"
)

var ErrRoleMemberNotFound = errors.New("chat member not found")

func (r *ChatRepository) GetMemberRole(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (domain.ChatMemberRole, error) {
	var role string

	err := r.db.QueryRow(ctx, `
		SELECT role::text
		FROM chat_members
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID).Scan(&role)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return "", ErrRoleMemberNotFound
		}

		return "", fmt.Errorf("get member role: %w", err)
	}

	return domain.ChatMemberRole(role), nil
}

func (r *ChatRepository) SetMemberRole(ctx context.Context, chatID uuid.UUID, userID uuid.UUID, role domain.ChatMemberRole) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE chat_members
		SET role = $3
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID, string(role))

	if err != nil {
		return fmt.Errorf("set member role: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrRoleMemberNotFound
	}

	return nil
}

func (r *ChatRepository) DeleteMember(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) error {
	tag, err := r.db.Exec(ctx, `
		DELETE FROM chat_members
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID)

	if err != nil {
		return fmt.Errorf("delete member: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrRoleMemberNotFound
	}

	return nil
}

func (r *ChatRepository) TransferOwnership(ctx context.Context, chatID uuid.UUID, oldOwnerID uuid.UUID, newOwnerID uuid.UUID) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin transfer ownership: %w", err)
	}

	defer func() {
		_ = tx.Rollback(ctx)
	}()

	_, err = tx.Exec(ctx, `
		UPDATE chat_members
		SET role = $3
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, oldOwnerID, string(domain.ChatMemberRoleAdmin))

	if err != nil {
		return fmt.Errorf("demote old owner: %w", err)
	}

	_, err = tx.Exec(ctx, `
		UPDATE chat_members
		SET role = $3
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, newOwnerID, string(domain.ChatMemberRoleOwner))

	if err != nil {
		return fmt.Errorf("promote new owner: %w", err)
	}

	_, err = tx.Exec(ctx, `
		UPDATE chats
		SET owner_id = $2
		WHERE id = $1
	`, chatID, newOwnerID)

	if err != nil {
		return fmt.Errorf("update chat owner: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit transfer ownership: %w", err)
	}

	return nil
}
