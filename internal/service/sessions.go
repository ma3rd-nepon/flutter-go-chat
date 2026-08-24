package service

import (
	"context"
	"errors"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var ErrSessionNotFound = errors.New("session not found")

type SessionService struct {
	tokens *repository.RefreshTokenRepository
}

func NewSessionService(tokens *repository.RefreshTokenRepository) *SessionService {
	return &SessionService{
		tokens: tokens,
	}
}

func (s *SessionService) List(ctx context.Context, userID uuid.UUID) ([]domain.RefreshToken, error) {
	return s.tokens.ListActiveSessions(ctx, userID)
}

func (s *SessionService) Revoke(ctx context.Context, userID uuid.UUID, sessionID uuid.UUID) error {
	err := s.tokens.RevokeByID(ctx, userID, sessionID)
	if err != nil {
		if errors.Is(err, repository.ErrRefreshSessionNotFound) {
			return ErrSessionNotFound
		}

		return err
	}

	return nil
}
