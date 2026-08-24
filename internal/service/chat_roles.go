package service

import (
	"context"
	"errors"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var (
	ErrNotOwner          = errors.New("owner only")
	ErrNotAdmin          = errors.New("admin or owner only")
	ErrCannotModifyOwner = errors.New("cannot modify owner")
	ErrMemberNotFound    = errors.New("member not found")
)

type RoleService struct {
	chats *repository.ChatRepository
}

func NewRoleService(chats *repository.ChatRepository) *RoleService {
	return &RoleService{
		chats: chats,
	}
}

func (s *RoleService) role(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (domain.ChatMemberRole, error) {
	role, err := s.chats.GetMemberRole(ctx, chatID, userID)
	if err != nil {
		if errors.Is(err, repository.ErrRoleMemberNotFound) {
			return "", ErrMemberNotFound
		}

		return "", err
	}

	return role, nil
}

func (s *RoleService) SetAdmin(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, targetID uuid.UUID) error {
	actorRole, err := s.role(ctx, chatID, actorID)
	if err != nil {
		return err
	}

	if actorRole != domain.ChatMemberRoleOwner {
		return ErrNotOwner
	}

	targetRole, err := s.role(ctx, chatID, targetID)
	if err != nil {
		return err
	}

	if targetRole == domain.ChatMemberRoleOwner {
		return ErrCannotModifyOwner
	}

	return s.chats.SetMemberRole(ctx, chatID, targetID, domain.ChatMemberRoleAdmin)
}

func (s *RoleService) RemoveAdmin(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, targetID uuid.UUID) error {
	actorRole, err := s.role(ctx, chatID, actorID)
	if err != nil {
		return err
	}

	if actorRole != domain.ChatMemberRoleOwner {
		return ErrNotOwner
	}

	targetRole, err := s.role(ctx, chatID, targetID)
	if err != nil {
		return err
	}

	if targetRole == domain.ChatMemberRoleOwner {
		return ErrCannotModifyOwner
	}

	return s.chats.SetMemberRole(ctx, chatID, targetID, domain.ChatMemberRoleMember)
}

func (s *RoleService) TransferOwner(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, targetID uuid.UUID) error {
	actorRole, err := s.role(ctx, chatID, actorID)
	if err != nil {
		return err
	}

	if actorRole != domain.ChatMemberRoleOwner {
		return ErrNotOwner
	}

	_, err = s.role(ctx, chatID, targetID)
	if err != nil {
		return err
	}

	return s.chats.TransferOwnership(ctx, chatID, actorID, targetID)
}

func (s *RoleService) Kick(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, targetID uuid.UUID) error {
	actorRole, err := s.role(ctx, chatID, actorID)
	if err != nil {
		return err
	}

	if actorRole != domain.ChatMemberRoleOwner && actorRole != domain.ChatMemberRoleAdmin {
		return ErrNotAdmin
	}

	targetRole, err := s.role(ctx, chatID, targetID)
	if err != nil {
		return err
	}

	if targetRole == domain.ChatMemberRoleOwner {
		return ErrCannotModifyOwner
	}

	if actorRole == domain.ChatMemberRoleAdmin && targetRole == domain.ChatMemberRoleAdmin {
		return ErrNotOwner
	}

	return s.chats.DeleteMember(ctx, chatID, targetID)
}
