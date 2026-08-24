package repository

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"supernova/internal/domain"
)

type NotificationRepository struct {
	db *pgxpool.Pool
}

func NewNotificationRepository(db *pgxpool.Pool) *NotificationRepository {
	return &NotificationRepository{db: db}
}

func (r *NotificationRepository) Create(ctx context.Context, notification *domain.Notification) error {
	if notification.ID == uuid.Nil {
		notification.ID = uuid.New()
	}

	if notification.CreatedAt.IsZero() {
		notification.CreatedAt = time.Now().UTC()
	}

	payload := []byte("{}")

	if notification.Payload != nil {
		var err error
		payload, err = json.Marshal(notification.Payload)
		if err != nil {
			return fmt.Errorf("marshal notification payload: %w", err)
		}
	}

	_, err := r.db.Exec(ctx, `
		INSERT INTO notifications (
			id,
			user_id,
			type,
			actor_id,
			chat_id,
			message_id,
			payload,
			read_at,
			created_at
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9
		)
	`,
		notification.ID,
		notification.UserID,
		string(notification.Type),
		notification.ActorID,
		notification.ChatID,
		notification.MessageID,
		payload,
		notification.ReadAt,
		notification.CreatedAt,
	)

	if err != nil {
		return fmt.Errorf("create notification: %w", err)
	}

	return nil
}

func (r *NotificationRepository) List(ctx context.Context, userID uuid.UUID, limit int) ([]domain.Notification, error) {
	rows, err := r.db.Query(ctx, `
		SELECT
			id,
			user_id,
			type,
			actor_id,
			chat_id,
			message_id,
			payload,
			read_at,
			created_at
		FROM notifications
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2
	`, userID, limit)

	if err != nil {
		return nil, fmt.Errorf("list notifications: %w", err)
	}

	defer rows.Close()

	items := make([]domain.Notification, 0, limit)

	for rows.Next() {
		notification, err := scanNotification(rows)
		if err != nil {
			return nil, err
		}

		items = append(items, notification)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("notification rows error: %w", err)
	}

	return items, nil
}

func (r *NotificationRepository) Read(ctx context.Context, userID uuid.UUID, ids []uuid.UUID) (int, error) {
	if len(ids) == 0 {
		return 0, nil
	}

	tag, err := r.db.Exec(ctx, `
		UPDATE notifications
		SET read_at = now()
		WHERE user_id = $1
		  AND read_at IS NULL
		  AND id = ANY($2)
	`, userID, ids)

	if err != nil {
		return 0, fmt.Errorf("read notifications: %w", err)
	}

	return int(tag.RowsAffected()), nil
}

func (r *NotificationRepository) ReadAll(ctx context.Context, userID uuid.UUID) (int, error) {
	tag, err := r.db.Exec(ctx, `
		UPDATE notifications
		SET read_at = now()
		WHERE user_id = $1
		  AND read_at IS NULL
	`, userID)

	if err != nil {
		return 0, fmt.Errorf("read all notifications: %w", err)
	}

	return int(tag.RowsAffected()), nil
}

func scanNotification(row pgx.Row) (domain.Notification, error) {
	var notification domain.Notification
	var notificationType string
	var payloadBytes []byte

	err := row.Scan(
		&notification.ID,
		&notification.UserID,
		&notificationType,
		&notification.ActorID,
		&notification.ChatID,
		&notification.MessageID,
		&payloadBytes,
		&notification.ReadAt,
		&notification.CreatedAt,
	)

	if err != nil {
		return domain.Notification{}, fmt.Errorf("scan notification: %w", err)
	}

	notification.Type = domain.NotificationType(notificationType)

	if len(payloadBytes) > 0 {
		if err := json.Unmarshal(payloadBytes, &notification.Payload); err != nil {
			notification.Payload = map[string]any{}
		}
	} else {
		notification.Payload = map[string]any{}
	}

	return notification, nil
}
