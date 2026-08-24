package service

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var (
	ErrCannotBlockSelf = errors.New("cannot block self")
	ErrUserNotFound    = errors.New("user not found")
)

type BlockService struct {
	blocks *repository.BlockRepository
	users  *repository.UserRepository
}

func NewBlockService(
	blocks *repository.BlockRepository,
	users *repository.UserRepository,
) *BlockService {
	return &BlockService{
		blocks: blocks,
		users:  users,
	}
}

func (s *BlockService) Block(ctx context.Context, blockerID uuid.UUID, blockedID uuid.UUID) (domain.Block, error) {
	if blockerID == blockedID {
		return domain.Block{}, ErrCannotBlockSelf
	}

	_, err := s.users.GetByID(ctx, blockedID.String())
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return domain.Block{}, ErrUserNotFound
		}

		return domain.Block{}, err
	}

	now := time.Now().UTC()

	if err := s.blocks.Block(ctx, blockerID, blockedID, now); err != nil {
		return domain.Block{}, err
	}

	return domain.Block{
		BlockerID: blockerID,
		BlockedID: blockedID,
		CreatedAt: now,
	}, nil
}

func (s *BlockService) Unblock(ctx context.Context, blockerID uuid.UUID, blockedID uuid.UUID) error {
	if blockerID == blockedID {
		return ErrCannotBlockSelf
	}

	return s.blocks.Unblock(ctx, blockerID, blockedID)
}

func (s *BlockService) List(ctx context.Context, blockerID uuid.UUID, limit int) ([]domain.BlockedUser, error) {
	return s.blocks.List(ctx, blockerID, limit)
}
