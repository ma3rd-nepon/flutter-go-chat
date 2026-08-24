package service

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var restrictionForever = muteForever

type RestrictionService struct {
	chats *repository.ChatRepository
}

func NewRestrictionService(chats *repository.ChatRepository) *RestrictionService {
	return &RestrictionService{chats: chats}
}

func (s *RestrictionService) Restrict(
	ctx context.Context,
	actorID uuid.UUID,
	chatID uuid.UUID,
	targetID uuid.UUID,
	durationSeconds *int,
	reason *string,
) error {
	if actorID == targetID {
		return ErrCannotModifyOwner
	}

	actorRole, err := s.chats.GetMemberRole(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrRoleMemberNotFound) {
			return ErrMemberNotFound
		}

		return err
	}

	if actorRole != domain.ChatMemberRoleOwner && actorRole != domain.ChatMemberRoleAdmin {
		return ErrNotAdmin
	}

	targetRole, err := s.chats.GetMemberRole(ctx, chatID, targetID)
	if err != nil {
		if errors.Is(err, repository.ErrRoleMemberNotFound) {
			return ErrMemberNotFound
		}

		return err
	}

	if targetRole == domain.ChatMemberRoleOwner {
		return ErrCannotModifyOwner
	}

	if actorRole == domain.ChatMemberRoleAdmin && targetRole == domain.ChatMemberRoleAdmin {
		return ErrNotOwner
	}

	until := restrictionForever

	if durationSeconds != nil && *durationSeconds > 0 {
		u := time.Now().UTC().Add(time.Duration(*durationSeconds) * time.Second)
		until = u
	}

	return s.chats.SetRestriction(ctx, chatID, targetID, &until, &actorID, reason)
}

func (s *RestrictionService) Unrestrict(
	ctx context.Context,
	actorID uuid.UUID,
	chatID uuid.UUID,
	targetID uuid.UUID,
) error {
	actorRole, err := s.chats.GetMemberRole(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrRoleMemberNotFound) {
			return ErrMemberNotFound
		}

		return err
	}

	if actorRole != domain.ChatMemberRoleOwner && actorRole != domain.ChatMemberRoleAdmin {
		return ErrNotAdmin
	}

	targetRole, err := s.chats.GetMemberRole(ctx, chatID, targetID)
	if err != nil {
		if errors.Is(err, repository.ErrRoleMemberNotFound) {
			return ErrMemberNotFound
		}

		return err
	}

	if targetRole == domain.ChatMemberRoleOwner {
		return ErrCannotModifyOwner
	}

	if actorRole == domain.ChatMemberRoleAdmin && targetRole == domain.ChatMemberRoleAdmin {
		return ErrNotOwner
	}

	return s.chats.SetRestriction(ctx, chatID, targetID, nil, nil, nil)
}
