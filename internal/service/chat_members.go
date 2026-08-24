package service

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var (
	ErrChatMemberNotFound = errors.New("chat member not found")
	ErrInvalidSettings    = errors.New("invalid settings")
)

type UpdateChatSettingsInput struct {
	AllowMemberInvite       *bool
	AllowMemberEditInfo     *bool
	AllowMemberSendMessages *bool
	SlowModeSeconds         *int
}

func (s *ChatService) AddMember(
	ctx context.Context,
	chatID uuid.UUID,
	actorID uuid.UUID,
	targetID uuid.UUID,
	role *string,
) (domain.ChatMember, bool, error) {
	view, err := s.Get(ctx, chatID, actorID)
	if err != nil {
		return domain.ChatMember{}, false, err
	}

	if view.Chat.Type == domain.ChatTypePrivate {
		return domain.ChatMember{}, false, ErrInvalidChatType
	}

	canInvite := view.Chat.AllowMemberInvite ||
		view.MyRole == domain.ChatMemberRoleOwner ||
		view.MyRole == domain.ChatMemberRoleAdmin

	if !canInvite {
		return domain.ChatMember{}, false, ErrForbidden
	}

	_, err = s.users.GetByID(ctx, targetID.String())
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return domain.ChatMember{}, false, ErrUserNotFound
		}

		return domain.ChatMember{}, false, err
	}

	existingMember, err := s.chats.GetMember(ctx, chatID, targetID)
	if err != nil && !errors.Is(err, repository.ErrChatMemberNotFound) {
		return domain.ChatMember{}, false, err
	}

	if existingMember != nil {
		return *existingMember, false, nil
	}

	memberRole := domain.ChatMemberRoleMember

	if role != nil {
		normalizedRole := strings.ToLower(strings.TrimSpace(*role))

		switch normalizedRole {
		case "member":
			memberRole = domain.ChatMemberRoleMember
		case "admin":
			if view.MyRole != domain.ChatMemberRoleOwner {
				return domain.ChatMember{}, false, ErrForbidden
			}
			memberRole = domain.ChatMemberRoleAdmin
		case "":
			memberRole = domain.ChatMemberRoleMember
		default:
			return domain.ChatMember{}, false, ErrInvalidMembers
		}
	}

	member := domain.ChatMember{
		ChatID:   chatID,
		UserID:   targetID,
		Role:     memberRole,
		IsPinned: false,
		JoinedAt: time.Now().UTC(),
	}

	if err := s.chats.AddMember(ctx, member); err != nil {
		return domain.ChatMember{}, false, err
	}

	return member, true, nil
}

func (s *ChatService) RemoveMember(
	ctx context.Context,
	chatID uuid.UUID,
	actorID uuid.UUID,
	targetID uuid.UUID,
) error {
	view, err := s.Get(ctx, chatID, actorID)
	if err != nil {
		return err
	}

	if view.Chat.Type == domain.ChatTypePrivate {
		return ErrInvalidChatType
	}

	targetMember, err := s.chats.GetMember(ctx, chatID, targetID)
	if err != nil {
		if errors.Is(err, repository.ErrChatMemberNotFound) {
			return ErrChatMemberNotFound
		}

		return err
	}

	if targetMember.Role == domain.ChatMemberRoleOwner {
		return ErrForbidden
	}

	// Выход из чата
	if actorID == targetID {
		return s.chats.RemoveMember(ctx, chatID, targetID)
	}

	// Владелец может удалять любых участников, кроме владельца
	if view.MyRole == domain.ChatMemberRoleOwner {
		return s.chats.RemoveMember(ctx, chatID, targetID)
	}

	// Админ может удалять только обычных участников
	if view.MyRole == domain.ChatMemberRoleAdmin {
		if targetMember.Role == domain.ChatMemberRoleAdmin {
			return ErrForbidden
		}

		return s.chats.RemoveMember(ctx, chatID, targetID)
	}

	return ErrForbidden
}

func (s *ChatService) SetPinned(
	ctx context.Context,
	chatID uuid.UUID,
	userID uuid.UUID,
	pinned bool,
) error {
	_, err := s.Get(ctx, chatID, userID)
	if err != nil {
		return err
	}

	err = s.chats.SetPinned(ctx, chatID, userID, pinned)
	if err != nil {
		if errors.Is(err, repository.ErrChatMemberNotFound) {
			return ErrChatMemberNotFound
		}

		return err
	}

	return nil
}

func (s *ChatService) UpdateSettings(
	ctx context.Context,
	chatID uuid.UUID,
	actorID uuid.UUID,
	input UpdateChatSettingsInput,
) (domain.ChatView, error) {
	view, err := s.Get(ctx, chatID, actorID)
	if err != nil {
		return domain.ChatView{}, err
	}

	if view.Chat.Type == domain.ChatTypePrivate {
		return domain.ChatView{}, ErrInvalidChatType
	}

	if view.MyRole != domain.ChatMemberRoleOwner && view.MyRole != domain.ChatMemberRoleAdmin {
		return domain.ChatView{}, ErrForbidden
	}

	if input.AllowMemberInvite != nil {
		view.Chat.AllowMemberInvite = *input.AllowMemberInvite
	}

	if input.AllowMemberEditInfo != nil {
		view.Chat.AllowMemberEditInfo = *input.AllowMemberEditInfo
	}

	if input.AllowMemberSendMessages != nil {
		view.Chat.AllowMemberSendMessages = *input.AllowMemberSendMessages
	}

	if input.SlowModeSeconds != nil {
		if *input.SlowModeSeconds < 0 {
			return domain.ChatView{}, ErrInvalidSettings
		}

		view.Chat.SlowModeSeconds = *input.SlowModeSeconds
	}

	err = s.chats.UpdateSettings(
		ctx,
		chatID,
		view.Chat.AllowMemberInvite,
		view.Chat.AllowMemberEditInfo,
		view.Chat.AllowMemberSendMessages,
		view.Chat.SlowModeSeconds,
	)

	if err != nil {
		return domain.ChatView{}, err
	}

	updatedView, err := s.Get(ctx, chatID, actorID)
	if err != nil {
		return domain.ChatView{}, err
	}

	return updatedView, nil
}
