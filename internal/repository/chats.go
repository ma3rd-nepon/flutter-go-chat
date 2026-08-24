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

var ErrChatNotFound = errors.New("chat not found")

type ChatRepository struct {
	db *pgxpool.Pool
}

func NewChatRepository(db *pgxpool.Pool) *ChatRepository {
	return &ChatRepository{db: db}
}

const chatViewColumns = `
	c.id,
	c.type,
	c.title,
	c.description,
	c.avatar_url,
	c.theme,
	c.owner_id,
	c.pinned_message_id,
	c.last_message_id,
	c.last_message_at,
	c.allow_member_invite,
	c.allow_member_edit_info,
	c.allow_member_send_messages,
	c.slow_mode_seconds,
	c.created_at,
	c.updated_at,
	COALESCE((SELECT count(*) FROM chat_members WHERE chat_id = c.id), 0) AS member_count,
	COALESCE(cm.is_pinned, false) AS is_pinned,
	COALESCE(cm.role::text, '') AS my_role,
	cm.user_id IS NOT NULL AS is_member
`

func scanChatView(row pgx.Row) (*domain.ChatView, error) {
	var view domain.ChatView
	var chatType string
	var myRole string

	err := row.Scan(
		&view.Chat.ID,
		&chatType,
		&view.Chat.Title,
		&view.Chat.Description,
		&view.Chat.AvatarURL,
		&view.Chat.Theme,
		&view.Chat.OwnerID,
		&view.Chat.PinnedMessageID,
		&view.Chat.LastMessageID,
		&view.Chat.LastMessageAt,
		&view.Chat.AllowMemberInvite,
		&view.Chat.AllowMemberEditInfo,
		&view.Chat.AllowMemberSendMessages,
		&view.Chat.SlowModeSeconds,
		&view.Chat.CreatedAt,
		&view.Chat.UpdatedAt,
		&view.MemberCount,
		&view.IsPinned,
		&myRole,
		&view.IsMember,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrChatNotFound
		}

		return nil, fmt.Errorf("scan chat view: %w", err)
	}

	view.Chat.Type = domain.ChatType(chatType)

	if myRole == "" {
		view.MyRole = domain.ChatMemberRoleMember
	} else {
		view.MyRole = domain.ChatMemberRole(myRole)
	}

	view.UnreadCount = 0

	return &view, nil
}

func (r *ChatRepository) GetChatView(ctx context.Context, chatID uuid.UUID, viewerID uuid.UUID) (*domain.ChatView, error) {
	row := r.db.QueryRow(ctx, `
		SELECT `+chatViewColumns+`
		FROM chats c
		LEFT JOIN chat_members cm
			ON cm.chat_id = c.id AND cm.user_id = $2
		WHERE c.id = $1
	`, chatID, viewerID)

	return scanChatView(row)
}

func (r *ChatRepository) ListChats(ctx context.Context, userID uuid.UUID, limit int) ([]domain.ChatView, error) {
	rows, err := r.db.Query(ctx, `
		SELECT `+chatViewColumns+`
		FROM chats c
		JOIN chat_members cm
			ON cm.chat_id = c.id AND cm.user_id = $1
		ORDER BY COALESCE(c.last_message_at, c.created_at) DESC
		LIMIT $2
	`, userID, limit)

	if err != nil {
		return nil, fmt.Errorf("list chats: %w", err)
	}

	defer rows.Close()

	items := make([]domain.ChatView, 0, limit)

	for rows.Next() {
		view, err := scanChatView(rows)
		if err != nil {
			return nil, err
		}

		items = append(items, *view)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("chat rows error: %w", err)
	}

	return items, nil
}

func (r *ChatRepository) GetPrivateChatIDBetween(ctx context.Context, userA uuid.UUID, userB uuid.UUID) (*uuid.UUID, error) {
	var chatID uuid.UUID

	err := r.db.QueryRow(ctx, `
		SELECT c.id
		FROM chats c
		JOIN chat_members m1 ON m1.chat_id = c.id AND m1.user_id = $1
		JOIN chat_members m2 ON m2.chat_id = c.id AND m2.user_id = $2
		WHERE c.type = $3
		LIMIT 1
	`, userA, userB, string(domain.ChatTypePrivate)).Scan(&chatID)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}

		return nil, fmt.Errorf("get private chat between users: %w", err)
	}

	return &chatID, nil
}

func (r *ChatRepository) Create(ctx context.Context, chat *domain.Chat, members []domain.ChatMember) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}

	defer func() {
		_ = tx.Rollback(ctx)
	}()

	now := time.Now().UTC()

	if chat.ID == uuid.Nil {
		chat.ID = uuid.New()
	}

	if chat.CreatedAt.IsZero() {
		chat.CreatedAt = now
	}

	chat.UpdatedAt = now

	_, err = tx.Exec(ctx, `
		INSERT INTO chats (
			id,
			type,
			title,
			description,
			avatar_url,
			theme,
			owner_id,
			last_message_id,
			last_message_at,
			allow_member_invite,
			allow_member_edit_info,
			allow_member_send_messages,
			slow_mode_seconds,
			created_at,
			updated_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15
		)
	`,
		chat.ID,
		string(chat.Type),
		chat.Title,
		chat.Description,
		chat.AvatarURL,
		chat.Theme,
		chat.OwnerID,
		chat.LastMessageID,
		chat.LastMessageAt,
		chat.AllowMemberInvite,
		chat.AllowMemberEditInfo,
		chat.AllowMemberSendMessages,
		chat.SlowModeSeconds,
		chat.CreatedAt,
		chat.UpdatedAt,
	)

	if err != nil {
		return fmt.Errorf("insert chat: %w", err)
	}

	for _, member := range members {
		if member.JoinedAt.IsZero() {
			member.JoinedAt = now
		}

		_, err = tx.Exec(ctx, `
			INSERT INTO chat_members (
				chat_id,
				user_id,
				role,
				is_pinned,
				last_read_message_id,
				joined_at
			) VALUES (
				$1, $2, $3, $4, $5, $6
			)
			ON CONFLICT (chat_id, user_id) DO NOTHING
		`,
			member.ChatID,
			member.UserID,
			string(member.Role),
			member.IsPinned,
			member.LastReadMessageID,
			member.JoinedAt,
		)

		if err != nil {
			return fmt.Errorf("insert chat member: %w", err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit tx: %w", err)
	}

	return nil
}

func (r *ChatRepository) UpdateChat(ctx context.Context, chat *domain.Chat) error {
	_, err := r.db.Exec(ctx, `
		UPDATE chats
		SET
			title = $2,
			description = $3,
			theme = $4
		WHERE id = $1
	`,
		chat.ID,
		chat.Title,
		chat.Description,
		chat.Theme,
	)

	if err != nil {
		return fmt.Errorf("update chat: %w", err)
	}

	return nil
}

func (r *ChatRepository) Delete(ctx context.Context, chatID uuid.UUID) error {
	_, err := r.db.Exec(ctx, `
		DELETE FROM chats
		WHERE id = $1
	`, chatID)

	if err != nil {
		return fmt.Errorf("delete chat: %w", err)
	}

	return nil
}
