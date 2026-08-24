package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type NotificationResponse struct {
	ID        uuid.UUID          `json:"id"`
	Type      string             `json:"type"`
	ActorID   *uuid.UUID         `json:"actor_id"`
	ChatID    *uuid.UUID         `json:"chat_id"`
	MessageID *uuid.UUID         `json:"message_id"`
	Payload   map[string]any     `json:"payload"`
	ReadAt    *unixtime.UnixTime `json:"read_at"`
	CreatedAt unixtime.UnixTime  `json:"created_at"`
}

type ReadNotificationsRequest struct {
	NotificationIDs []uuid.UUID `json:"notification_ids"`
}

func NewNotificationResponse(notification domain.Notification) NotificationResponse {
	payload := notification.Payload
	if payload == nil {
		payload = map[string]any{}
	}

	return NotificationResponse{
		ID:        notification.ID,
		Type:      string(notification.Type),
		ActorID:   notification.ActorID,
		ChatID:    notification.ChatID,
		MessageID: notification.MessageID,
		Payload:   payload,
		ReadAt:    unixtime.NewPtr(notification.ReadAt),
		CreatedAt: unixtime.New(notification.CreatedAt),
	}
}
