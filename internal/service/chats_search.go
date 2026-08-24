package service

import (
	"context"

	"github.com/google/uuid"

	"supernova/internal/domain"
)

func (s *ChatService) Search(ctx context.Context, userID uuid.UUID, q string, limit int) ([]domain.ChatView, error) {
	return s.chats.Search(ctx, userID, q, limit)
}
