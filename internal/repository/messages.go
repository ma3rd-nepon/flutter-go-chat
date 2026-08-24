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

var ErrMessageNotFound = errors.New("message not found")

type MessageRepository struct {
	db *pgxpool.Pool
}

func NewMessageRepository(db *pgxpool.Pool) *MessageRepository {
	return &MessageRepository{db: db}
}

const messageColumns = `
	id,
	chat_id,
	sender_id,
	kind,
	text,
	attachment_url,
	attachment_id,
	reply_to_id,
	forwarded_from_id,
	is_edited,
	is_deleted,
	is_pinned,
	created_at,
	updated_at,
	deleted_at
`

func scanMessage(row pgx.Row) (*domain.Message, error) {
	var message domain.Message
	var kind string

	err := row.Scan(
		&message.ID,
		&message.ChatID,
		&message.SenderID,
		&kind,
		&message.Text,
		&message.AttachmentURL,
		&message.AttachmentID,
		&message.ReplyToID,
		&message.ForwardedFromID,
		&message.IsEdited,
		&message.IsDeleted,
		&message.IsPinned,
		&message.CreatedAt,
		&message.UpdatedAt,
		&message.DeletedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrMessageNotFound
		}

		return nil, fmt.Errorf("scan message: %w", err)
	}

	message.Kind = domain.MessageKind(kind)

	return &message, nil
}

func (r *MessageRepository) Create(ctx context.Context, message *domain.Message) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}

	defer func() {
		_ = tx.Rollback(ctx)
	}()

	now := time.Now().UTC()

	if message.ID == uuid.Nil {
		message.ID = uuid.New()
	}

	if message.CreatedAt.IsZero() {
		message.CreatedAt = now
	}

	message.UpdatedAt = now

	if message.Kind == "" {
		message.Kind = domain.MessageKindText
	}

	_, err = tx.Exec(ctx, `
		INSERT INTO messages (
			id,
			chat_id,
			sender_id,
			kind,
			text,
			attachment_url,
			attachment_id,
			reply_to_id,
			forwarded_from_id,
			is_edited,
			is_deleted,
			is_pinned,
			created_at,
			updated_at,
			deleted_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15
		)
	`,
		message.ID,
		message.ChatID,
		message.SenderID,
		string(message.Kind),
		message.Text,
		message.AttachmentURL,
		message.AttachmentID,
		message.ReplyToID,
		message.ForwardedFromID,
		message.IsEdited,
		message.IsDeleted,
		message.IsPinned,
		message.CreatedAt,
		message.UpdatedAt,
		message.DeletedAt,
	)

	if err != nil {
		return fmt.Errorf("insert message: %w", err)
	}

	_, err = tx.Exec(ctx, `
		UPDATE chats
		SET
			last_message_id = $2,
			last_message_at = $3
		WHERE id = $1
	`,
		message.ChatID,
		message.ID,
		message.CreatedAt,
	)

	if err != nil {
		return fmt.Errorf("update chat last message: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit tx: %w", err)
	}

	return nil
}

func (r *MessageRepository) GetByID(ctx context.Context, messageID uuid.UUID) (*domain.Message, error) {
	row := r.db.QueryRow(ctx, `
		SELECT `+messageColumns+`
		FROM messages
		WHERE id = $1
	`, messageID)

	return scanMessage(row)
}

func (r *MessageRepository) ListByChat(ctx context.Context, chatID uuid.UUID, limit int) ([]domain.Message, error) {
	rows, err := r.db.Query(ctx, `
		SELECT `+messageColumns+`
		FROM messages
		WHERE chat_id = $1
		ORDER BY created_at DESC
		LIMIT $2
	`, chatID, limit)

	if err != nil {
		return nil, fmt.Errorf("list messages: %w", err)
	}

	defer rows.Close()

	items := make([]domain.Message, 0, limit)

	for rows.Next() {
		message, err := scanMessage(rows)
		if err != nil {
			return nil, err
		}

		items = append(items, *message)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("message rows error: %w", err)
	}

	return items, nil
}

func (r *MessageRepository) UpdateText(ctx context.Context, messageID uuid.UUID, text string) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE messages
		SET
			text = $2,
			is_edited = true,
			updated_at = now()
		WHERE id = $1 AND is_deleted = false
	`, messageID, text)

	if err != nil {
		return fmt.Errorf("update message text: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrMessageNotFound
	}

	return nil
}

func (r *MessageRepository) SoftDelete(ctx context.Context, messageID uuid.UUID) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE messages
		SET
			is_deleted = true,
			deleted_at = now(),
			updated_at = now()
		WHERE id = $1 AND is_deleted = false
	`, messageID)

	if err != nil {
		return fmt.Errorf("soft delete message: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrMessageNotFound
	}

	return nil
}

func (r *MessageRepository) MarkRead(ctx context.Context, chatID uuid.UUID, userID uuid.UUID, messageID uuid.UUID) error {
	tag, err := r.db.Exec(ctx, `
		UPDATE chat_members
		SET last_read_message_id = $3
		WHERE chat_id = $1
		  AND user_id = $2
		  AND EXISTS (
			SELECT 1
			FROM messages
			WHERE id = $3 AND chat_id = $1
		  )
	`, chatID, userID, messageID)

	if err != nil {
		return fmt.Errorf("mark chat read: %w", err)
	}

	if tag.RowsAffected() == 0 {
		return ErrMessageNotFound
	}

	return nil
}
