package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"

	"supernova/internal/domain"
)

var ErrChatMemberNotFound = errors.New("chat member not found")

func (r *ChatRepository) GetMember(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (*domain.ChatMember, error) {
	row := r.db.QueryRow(ctx, `
		SELECT
			chat_id,
			user_id,
			role,
			is_pinned,
			muted_until,
			restricted_until,
			restricted_by,
			restricted_reason,
			last_read_message_id,
			joined_at
		FROM chat_members
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID)

	var member domain.ChatMember
	var role string

	err := row.Scan(
		&member.ChatID,
		&member.UserID,
		&role,
		&member.IsPinned,
		&member.MutedUntil,
		&member.RestrictedUntil,
		&member.RestrictedBy,
		&member.RestrictedReason,
		&member.LastReadMessageID,
		&member.JoinedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrChatMemberNotFound
		}

		return nil, fmt.Errorf("get chat member: %w", err)
	}

	member.Role = domain.ChatMemberRole(role)

	return &member, nil
}

func (r *ChatRepository) AddMember(ctx context.Context, member domain.ChatMember) error {
	if member.JoinedAt.IsZero() {
		member.JoinedAt = time.Now().UTC()
	}

	_, err := r.db.Exec(ctx, `
		INSERT INTO chat_members (
			chat_id,
			user_id,
			role,
			is_pinned,
			muted_until,
			restricted_until,
			restricted_by,
			restricted_reason,
			joined_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9
		)
		ON CONFLICT (chat_id, user_id) DO NOTHING
	`,
		member.ChatID,
		member.UserID,
		string(member.Role),
		member.IsPinned,
		member.MutedUntil,
		member.RestrictedUntil,
		member.RestrictedBy,
		member.RestrictedReason,
		member.JoinedAt,
	)

	if err != nil {
		return fmt.Errorf("add chat member: %w", err)
	}

	return nil
}

func (r *ChatRepository) RemoveMember(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) error {
	_, err := r.db.Exec(ctx, `
		DELETE FROM chat_members
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID)

	if err != nil {
		return fmt.Errorf("remove chat member: %w", err)
	}

	return nil
}

func (r *ChatRepository) SetPinned(ctx context.Context, chatID uuid.UUID, userID uuid.UUID, pinned bool) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE chat_members
		SET is_pinned = $3
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID, pinned)

	if err != nil {
		return fmt.Errorf("set chat pinned: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrChatMemberNotFound
	}

	return nil
}

func (r *ChatRepository) SetMute(ctx context.Context, chatID uuid.UUID, userID uuid.UUID, mutedUntil *time.Time) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE chat_members
		SET muted_until = $3
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID, mutedUntil)

	if err != nil {
		return fmt.Errorf("set chat mute: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrChatMemberNotFound
	}

	return nil
}

func (r *ChatRepository) GetMuteUntil(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (*time.Time, error) {
	var mutedUntil *time.Time

	err := r.db.QueryRow(ctx, `
		SELECT muted_until
		FROM chat_members
		WHERE chat_id = $1 AND user_id = $2
	`, chatID, userID).Scan(&mutedUntil)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrChatMemberNotFound
		}

		return nil, fmt.Errorf("get mute until: %w", err)
	}

	return mutedUntil, nil
}

func (r *ChatRepository) IsMuted(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (bool, error) {
	var muted bool

	err := r.db.QueryRow(ctx, `
		SELECT EXISTS (
			SELECT 1
			FROM chat_members
			WHERE chat_id = $1
			  AND user_id = $2
			  AND muted_until IS NOT NULL
			  AND muted_until > now()
		)
	`, chatID, userID).Scan(&muted)

	if err != nil {
		return false, fmt.Errorf("check chat mute: %w", err)
	}

	return muted, nil
}

func (r *ChatRepository) UpdateSettings(
	ctx context.Context,
	chatID uuid.UUID,
	allowMemberInvite bool,
	allowMemberEditInfo bool,
	allowMemberSendMessages bool,
	slowModeSeconds int,
) error {
	_, err := r.db.Exec(ctx, `
		UPDATE chats
		SET
			allow_member_invite = $2,
			allow_member_edit_info = $3,
			allow_member_send_messages = $4,
			slow_mode_seconds = $5
		WHERE id = $1
	`,
		chatID,
		allowMemberInvite,
		allowMemberEditInfo,
		allowMemberSendMessages,
		slowModeSeconds,
	)

	if err != nil {
		return fmt.Errorf("update chat settings: %w", err)
	}

	return nil
}
