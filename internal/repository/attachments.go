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

var ErrAttachmentNotFound = errors.New("attachment not found")

type AttachmentRepository struct {
	db *pgxpool.Pool
}

func NewAttachmentRepository(db *pgxpool.Pool) *AttachmentRepository {
	return &AttachmentRepository{db: db}
}

const attachmentColumns = `
	id,
	chat_id,
	uploader_id,
	url,
	filename,
	mime_type,
	size_bytes,
	kind,
	width,
	height,
	created_at
`

func scanAttachment(row pgx.Row) (*domain.Attachment, error) {
	var a domain.Attachment
	var kind string

	err := row.Scan(
		&a.ID,
		&a.ChatID,
		&a.UploaderID,
		&a.URL,
		&a.Filename,
		&a.MimeType,
		&a.SizeBytes,
		&kind,
		&a.Width,
		&a.Height,
		&a.CreatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrAttachmentNotFound
		}

		return nil, fmt.Errorf("scan attachment: %w", err)
	}

	a.Kind = domain.MessageKind(kind)

	return &a, nil
}

func (r *AttachmentRepository) Create(ctx context.Context, a *domain.Attachment) error {
	if a.ID == uuid.Nil {
		a.ID = uuid.New()
	}

	if a.CreatedAt.IsZero() {
		a.CreatedAt = time.Now().UTC()
	}

	_, err := r.db.Exec(ctx, `
		INSERT INTO attachments (
			id,
			chat_id,
			uploader_id,
			url,
			filename,
			mime_type,
			size_bytes,
			kind,
			width,
			height,
			created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
		)
	`,
		a.ID,
		a.ChatID,
		a.UploaderID,
		a.URL,
		a.Filename,
		a.MimeType,
		a.SizeBytes,
		string(a.Kind),
		a.Width,
		a.Height,
		a.CreatedAt,
	)

	if err != nil {
		return fmt.Errorf("insert attachment: %w", err)
	}

	return nil
}

func (r *AttachmentRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.Attachment, error) {
	row := r.db.QueryRow(ctx, `
		SELECT `+attachmentColumns+`
		FROM attachments
		WHERE id = $1
	`, id)

	return scanAttachment(row)
}

func (r *AttachmentRepository) GetByIDs(ctx context.Context, ids []uuid.UUID) (map[uuid.UUID]*domain.Attachment, error) {
	result := make(map[uuid.UUID]*domain.Attachment, len(ids))

	if len(ids) == 0 {
		return result, nil
	}

	rows, err := r.db.Query(ctx, `
		SELECT `+attachmentColumns+`
		FROM attachments
		WHERE id = ANY($1::uuid[])
	`, ids)

	if err != nil {
		return nil, fmt.Errorf("get attachments by ids: %w", err)
	}

	defer rows.Close()

	for rows.Next() {
		a, err := scanAttachment(rows)
		if err != nil {
			return nil, err
		}

		result[a.ID] = a
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("attachments rows error: %w", err)
	}

	return result, nil
}
