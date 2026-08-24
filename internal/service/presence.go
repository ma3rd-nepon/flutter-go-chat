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

type PresenceService struct {
	users   *repository.UserRepository
	friends *repository.FriendRepository
	hub     *ws.Hub
}

func NewPresenceService(
	users *repository.UserRepository,
	friends *repository.FriendRepository,
	hub *ws.Hub,
) *PresenceService {
	return &PresenceService{
		users:   users,
		friends: friends,
		hub:     hub,
	}
}

func (s *PresenceService) SetOnline(userID uuid.UUID) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := s.users.SetPresence(ctx, userID, domain.UserStatusOnline, nil); err != nil {
		slog.Error("failed to set online status", "user_id", userID, "error", err)
		return
	}

	s.broadcast(ctx, userID, domain.UserStatusOnline, nil)
}

func (s *PresenceService) SetOffline(userID uuid.UUID) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	now := time.Now().UTC()

	if err := s.users.SetPresence(ctx, userID, domain.UserStatusOffline, &now); err != nil {
		slog.Error("failed to set offline status", "user_id", userID, "error", err)
		return
	}

	s.broadcast(ctx, userID, domain.UserStatusOffline, &now)
}

func (s *PresenceService) broadcast(
	ctx context.Context,
	userID uuid.UUID,
	status domain.UserStatus,
	lastSeen *time.Time,
) {
	friendIDs, err := s.friends.ListFriendIDs(ctx, userID)
	if err != nil {
		slog.Error("failed to get friend ids for presence broadcast", "user_id", userID, "error", err)
		return
	}

	userIDs := make([]uuid.UUID, 0, len(friendIDs)+1)
	userIDs = append(userIDs, friendIDs...)
	userIDs = append(userIDs, userID)

	data := map[string]any{
		"user_id":   userID.String(),
		"status":    string(status),
		"last_seen": nil,
	}

	if lastSeen != nil {
		data["last_seen"] = lastSeen.Unix()
	}

	event := ws.NewEvent(ws.EventPresenceChanged, nil, data)

	s.hub.BroadcastToUsers(userIDs, event, nil)
}
