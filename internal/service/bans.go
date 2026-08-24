package service

import (
	"context"
	"errors"
	"strings"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var (
	ErrUserBanned    = errors.New("user is banned in this chat")
	ErrCannotAddSelf = errors.New("cannot add yourself")
	ErrInvalidRole   = errors.New("invalid role")
)

type BanService struct {
	bans  *repository.ChatBanRepository
	chats *repository.ChatRepository
}

func NewBanService(bans *repository.ChatBanRepository, chats *repository.ChatRepository) *BanService {
	return &BanService{
		bans:  bans,
		chats: chats,
	}
}

func (s *BanService) Ban(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, targetID uuid.UUID, reason *string) error {
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

	targetIsMember := true

	if err != nil {
		if errors.Is(err, repository.ErrRoleMemberNotFound) {
			targetIsMember = false
		} else {
			return err
		}
	}

	if targetIsMember && targetRole == domain.ChatMemberRoleOwner {
		return ErrCannotModifyOwner
	}

	ban := domain.ChatBan{
		ChatID:   chatID,
		UserID:   targetID,
		BannedBy: &actorID,
		Reason:   reason,
	}

	if err := s.bans.Ban(ctx, ban); err != nil {
		return err
	}

	if targetIsMember {
		_ = s.chats.DeleteMember(ctx, chatID, targetID)
	}

	return nil
}

func (s *BanService) Unban(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, targetID uuid.UUID) error {
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

	return s.bans.Unban(ctx, chatID, targetID)
}

func (s *BanService) List(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID) ([]domain.ChatBanView, error) {
	_, err := s.chats.GetMemberRole(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrRoleMemberNotFound) {
			return nil, ErrMemberNotFound
		}

		return nil, err
	}

	return s.bans.List(ctx, chatID)
}

func (s *BanService) AddMember(ctx context.Context, actorID uuid.UUID, chatID uuid.UUID, targetID uuid.UUID, role *string) error {
	if actorID == targetID {
		return ErrCannotAddSelf
	}

	view, err := s.chats.GetChatView(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return ErrChatNotFound
		}

		return err
	}

	if !view.IsMember {
		return ErrChatNotFound
	}

	canInvite := view.Chat.AllowMemberInvite ||
		view.MyRole == domain.ChatMemberRoleOwner ||
		view.MyRole == domain.ChatMemberRoleAdmin

	if !canInvite {
		return ErrForbidden
	}

	banned, err := s.bans.IsBanned(ctx, chatID, targetID)
	if err != nil {
		return err
	}

	if banned {
		return ErrUserBanned
	}

	memberRole := domain.ChatMemberRoleMember

	if role != nil {
		normalizedRole := strings.ToLower(strings.TrimSpace(*role))

		switch normalizedRole {
		case "", "member":
			memberRole = domain.ChatMemberRoleMember
		case "admin":
			if view.MyRole != domain.ChatMemberRoleOwner {
				return ErrNotOwner
			}
			memberRole = domain.ChatMemberRoleAdmin
		default:
			return ErrInvalidRole
		}
	}

	member := domain.ChatMember{
		ChatID: chatID,
		UserID: targetID,
		Role:   memberRole,
	}

	err = s.chats.AddMember(ctx, member)
	if err != nil {
		if strings.Contains(err.Error(), "user is banned") {
			return ErrUserBanned
		}

		return err
	}

	return nil
}
