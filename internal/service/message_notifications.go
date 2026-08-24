package service

import (
	"context"
	"log/slog"
	"regexp"
	"strings"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
	"supernova/internal/ws"
)

var mentionRegex = regexp.MustCompile(`@([a-zA-Z0-9_]{3,32})`)

type MessageNotificationService struct {
	notifications *repository.NotificationRepository
	chats         *repository.ChatRepository
	users         *repository.UserRepository
	hub           *ws.Hub
}

func NewMessageNotificationService(
	notifications *repository.NotificationRepository,
	chats *repository.ChatRepository,
	users *repository.UserRepository,
	hub *ws.Hub,
) *MessageNotificationService {
	return &MessageNotificationService{
		notifications: notifications,
		chats:         chats,
		users:         users,
		hub:           hub,
	}
}

func (s *MessageNotificationService) NotifyNewMessage(ctx context.Context, message domain.Message) {
	if message.SenderID == nil {
		return
	}

	memberIDs, err := s.chats.ListMemberIDs(ctx, message.ChatID)
	if err != nil {
		slog.Error("failed to get chat member ids for message notification",
			"chat_id", message.ChatID,
			"error", err,
		)
		return
	}

	mentionedIDs := s.parseMentionedUserIDs(ctx, message.Text)

	for _, memberID := range memberIDs {
		if memberID == *message.SenderID {
			continue
		}

		muted, err := s.chats.IsMuted(ctx, message.ChatID, memberID)
		if err != nil {
			slog.Error("failed to check mute for message notification",
				"chat_id", message.ChatID,
				"user_id", memberID,
				"error", err,
			)
			continue
		}

		if muted {
			continue
		}

		notificationType := domain.NotificationTypeMessage
		mentioned := mentionedIDs[memberID]

		if mentioned {
			notificationType = domain.NotificationTypeMention
		}

		notification := domain.Notification{
			ID:        uuid.New(),
			UserID:    memberID,
			Type:      notificationType,
			ActorID:   message.SenderID,
			ChatID:    &message.ChatID,
			MessageID: &message.ID,
			Payload: map[string]any{
				"message_id": message.ID,
				"chat_id":    message.ChatID,
				"preview":    messagePreview(message),
				"mentioned":  mentioned,
			},
			CreatedAt: time.Now().UTC(),
		}

		if err := s.notifications.Create(ctx, &notification); err != nil {
			slog.Error("failed to create message notification",
				"chat_id", message.ChatID,
				"user_id", memberID,
				"error", err,
			)
			continue
		}

		s.hub.BroadcastToUser(
			memberID,
			ws.NewEvent(ws.EventNotification, nil, map[string]any{
				"notification": s.notificationData(notification),
			}),
		)
	}
}

func (s *MessageNotificationService) parseMentionedUserIDs(ctx context.Context, text *string) map[uuid.UUID]bool {
	result := make(map[uuid.UUID]bool)

	usernames := parseMentionUsernames(text)

	for _, username := range usernames {
		user, err := s.users.GetByUsername(ctx, username)
		if err != nil || user == nil {
			continue
		}

		result[user.ID] = true
	}

	return result
}

func parseMentionUsernames(text *string) []string {
	if text == nil || *text == "" {
		return nil
	}

	matches := mentionRegex.FindAllStringSubmatch(*text, -1)
	if len(matches) == 0 {
		return nil
	}

	seen := make(map[string]struct{}, len(matches))
	usernames := make([]string, 0, len(matches))

	for _, match := range matches {
		if len(match) < 2 {
			continue
		}

		username := strings.ToLower(strings.TrimSpace(match[1]))

		if username == "" {
			continue
		}

		if _, ok := seen[username]; ok {
			continue
		}

		seen[username] = struct{}{}
		usernames = append(usernames, username)
	}

	return usernames
}

func (s *MessageNotificationService) notificationData(notification domain.Notification) map[string]any {
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

func messagePreview(message domain.Message) string {
	if message.Text != nil && *message.Text != "" {
		return truncateString(*message.Text, 80)
	}

	if message.AttachmentURL != nil && *message.AttachmentURL != "" {
		return "Вложение"
	}

	return "Сообщение"
}

func truncateString(s string, max int) string {
	runes := []rune(s)

	if len(runes) <= max {
		return s
	}

	return string(runes[:max]) + "..."
}
