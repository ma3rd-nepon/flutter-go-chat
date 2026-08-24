package service

import (
	"context"
	"log/slog"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
	"supernova/internal/ws"
)

type NotificationService struct {
	repo *repository.NotificationRepository
	hub  *ws.Hub
}

func NewNotificationService(repo *repository.NotificationRepository, hub *ws.Hub) *NotificationService {
	return &NotificationService{
		repo: repo,
		hub:  hub,
	}
}

func (s *NotificationService) List(ctx context.Context, userID uuid.UUID, limit int) ([]domain.Notification, error) {
	return s.repo.List(ctx, userID, limit)
}

func (s *NotificationService) Read(ctx context.Context, userID uuid.UUID, ids []uuid.UUID) (int, error) {
	return s.repo.Read(ctx, userID, ids)
}

func (s *NotificationService) ReadAll(ctx context.Context, userID uuid.UUID) (int, error) {
	return s.repo.ReadAll(ctx, userID)
}

func (s *NotificationService) NotifyFriendRequest(ctx context.Context, actorID uuid.UUID, targetUserID uuid.UUID, friendID uuid.UUID) {
	notification := domain.Notification{
		UserID:  targetUserID,
		Type:    domain.NotificationTypeFriendRequest,
		ActorID: &actorID,
		Payload: map[string]any{
			"friend_id": friendID,
		},
	}

	s.notify(ctx, notification)
}

func (s *NotificationService) NotifyFriendAccepted(ctx context.Context, actorID uuid.UUID, targetUserID uuid.UUID, friendID uuid.UUID) {
	notification := domain.Notification{
		UserID:  targetUserID,
		Type:    domain.NotificationTypeFriendAccepted,
		ActorID: &actorID,
		Payload: map[string]any{
			"friend_id": friendID,
		},
	}

	s.notify(ctx, notification)
}

func (s *NotificationService) notify(ctx context.Context, notification domain.Notification) {
	if notification.ID == uuid.Nil {
		notification.ID = uuid.New()
	}

	if notification.CreatedAt.IsZero() {
		notification.CreatedAt = time.Now().UTC()
	}

	if notification.Payload == nil {
		notification.Payload = map[string]any{}
	}

	if err := s.repo.Create(ctx, &notification); err != nil {
		slog.Error("failed to create notification", "error", err)
		return
	}

	s.hub.BroadcastToUser(
		notification.UserID,
		ws.NewEvent(ws.EventNotification, nil, map[string]any{
			"notification": notificationData(notification),
		}),
	)
}

func notificationData(notification domain.Notification) map[string]any {
	data := map[string]any{
		"id":         notification.ID,
		"type":       string(notification.Type),
		"actor_id":   nil,
		"chat_id":    nil,
		"message_id": nil,
		"payload":    notification.Payload,
		"read_at":    nil,
		"created_at": notification.CreatedAt.Unix(),
	}

	if notification.ActorID != nil {
		data["actor_id"] = *notification.ActorID
	}

	if notification.ChatID != nil {
		data["chat_id"] = *notification.ChatID
	}

	if notification.MessageID != nil {
		data["message_id"] = *notification.MessageID
	}

	if notification.ReadAt != nil {
		data["read_at"] = notification.ReadAt.Unix()
	}

	return data
}
