package service

import (
	"context"
	"log/slog"

	"github.com/google/uuid"

	"supernova/internal/repository"
	"supernova/internal/ws"
)

type EventService struct {
	hub   *ws.Hub
	chats *repository.ChatRepository
}

func NewEventService(hub *ws.Hub, chats *repository.ChatRepository) *EventService {
	return &EventService{
		hub:   hub,
		chats: chats,
	}
}

func (s *EventService) BroadcastChatEvent(
	ctx context.Context,
	chatID uuid.UUID,
	exceptUserID *uuid.UUID,
	event ws.Event,
) {
	userIDs, err := s.chats.ListMemberIDs(ctx, chatID)
	if err != nil {
		slog.Error("failed to get chat member ids for broadcast",
			"chat_id", chatID,
			"error", err,
		)
		return
	}

	s.hub.BroadcastToUsers(userIDs, event, exceptUserID)
}

func (s *EventService) BroadcastChatEventIfMember(
	ctx context.Context,
	chatID uuid.UUID,
	actorID uuid.UUID,
	exceptUserID *uuid.UUID,
	event ws.Event,
) {
	view, err := s.chats.GetChatView(ctx, chatID, actorID)
	if err != nil || !view.IsMember {
		return
	}

	userIDs, err := s.chats.ListMemberIDs(ctx, chatID)
	if err != nil {
		slog.Error("failed to get chat member ids for member broadcast",
			"chat_id", chatID,
			"error", err,
		)
		return
	}

	s.hub.BroadcastToUsers(userIDs, event, exceptUserID)
}

func (s *EventService) MemberIDs(ctx context.Context, chatID uuid.UUID) ([]uuid.UUID, error) {
	return s.chats.ListMemberIDs(ctx, chatID)
}

func (s *EventService) Broadcast(userIDs []uuid.UUID, exceptUserID *uuid.UUID, event ws.Event) {
	s.hub.BroadcastToUsers(userIDs, event, exceptUserID)
}
