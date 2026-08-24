package service

import (
	"context"
	"errors"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var (
	ErrInvalidChatType = errors.New("invalid chat type")
	ErrTitleRequired   = errors.New("title is required")
	ErrInvalidMembers  = errors.New("invalid members")
	ErrChatNotFound    = errors.New("chat not found")
	ErrForbidden       = errors.New("forbidden")
)

type ChatService struct {
	chats *repository.ChatRepository
	users *repository.UserRepository
}

func NewChatService(
	chats *repository.ChatRepository,
	users *repository.UserRepository,
) *ChatService {
	return &ChatService{
		chats: chats,
		users: users,
	}
}

type CreateChatInput struct {
	Type        domain.ChatType
	Title       *string
	Description *string
	MemberIDs   []uuid.UUID
}

type UpdateChatInput struct {
	Title       *string
	Description *string
	Theme       *string
}

func (s *ChatService) Create(ctx context.Context, creatorID uuid.UUID, input CreateChatInput) (domain.ChatView, bool, error) {
	switch input.Type {
	case domain.ChatTypePrivate, domain.ChatTypeGroup, domain.ChatTypeChannel:
	default:
		return domain.ChatView{}, false, ErrInvalidChatType
	}

	if input.Type == domain.ChatTypePrivate {
		return s.createPrivateChat(ctx, creatorID, input)
	}

	return s.createGroupChat(ctx, creatorID, input)
}

func (s *ChatService) createPrivateChat(ctx context.Context, creatorID uuid.UUID, input CreateChatInput) (domain.ChatView, bool, error) {
	if len(input.MemberIDs) != 1 {
		return domain.ChatView{}, false, ErrInvalidMembers
	}

	otherID := input.MemberIDs[0]

	if otherID == creatorID {
		return domain.ChatView{}, false, ErrInvalidMembers
	}

	_, err := s.users.GetByID(ctx, otherID.String())
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return domain.ChatView{}, false, ErrUserNotFound
		}

		return domain.ChatView{}, false, err
	}

	existingChatID, err := s.chats.GetPrivateChatIDBetween(ctx, creatorID, otherID)
	if err != nil {
		return domain.ChatView{}, false, err
	}

	if existingChatID != nil {
		view, err := s.chats.GetChatView(ctx, *existingChatID, creatorID)
		if err != nil {
			return domain.ChatView{}, false, err
		}

		return *view, false, nil
	}

	chat := domain.Chat{
		ID:                      uuid.New(),
		Type:                    domain.ChatTypePrivate,
		Title:                   nil,
		Description:             normalizeOptionalString(input.Description),
		AvatarURL:               nil,
		Theme:                   nil,
		OwnerID:                 nil,
		LastMessageID:           nil,
		LastMessageAt:           nil,
		AllowMemberInvite:       false,
		AllowMemberEditInfo:     false,
		AllowMemberSendMessages: true,
		SlowModeSeconds:         0,
	}

	members := []domain.ChatMember{
		{
			ChatID: chat.ID,
			UserID: creatorID,
			Role:   domain.ChatMemberRoleMember,
		},
		{
			ChatID: chat.ID,
			UserID: otherID,
			Role:   domain.ChatMemberRoleMember,
		},
	}

	if err := s.chats.Create(ctx, &chat, members); err != nil {
		return domain.ChatView{}, false, err
	}

	view, err := s.chats.GetChatView(ctx, chat.ID, creatorID)
	if err != nil {
		return domain.ChatView{}, false, err
	}

	return *view, true, nil
}

func (s *ChatService) createGroupChat(ctx context.Context, creatorID uuid.UUID, input CreateChatInput) (domain.ChatView, bool, error) {
	title := normalizeOptionalString(input.Title)
	if title == nil {
		return domain.ChatView{}, false, ErrTitleRequired
	}

	chat := domain.Chat{
		ID:                      uuid.New(),
		Type:                    input.Type,
		Title:                   title,
		Description:             normalizeOptionalString(input.Description),
		AvatarURL:               nil,
		Theme:                   nil,
		OwnerID:                 &creatorID,
		LastMessageID:           nil,
		LastMessageAt:           nil,
		AllowMemberInvite:       true,
		AllowMemberEditInfo:     false,
		AllowMemberSendMessages: true,
		SlowModeSeconds:         0,
	}

	members := []domain.ChatMember{
		{
			ChatID: chat.ID,
			UserID: creatorID,
			Role:   domain.ChatMemberRoleOwner,
		},
	}

	added := map[uuid.UUID]bool{
		creatorID: true,
	}

	for _, memberID := range input.MemberIDs {
		if added[memberID] {
			continue
		}

		_, err := s.users.GetByID(ctx, memberID.String())
		if err != nil {
			if errors.Is(err, repository.ErrUserNotFound) {
				return domain.ChatView{}, false, ErrUserNotFound
			}

			return domain.ChatView{}, false, err
		}

		members = append(members, domain.ChatMember{
			ChatID: chat.ID,
			UserID: memberID,
			Role:   domain.ChatMemberRoleMember,
		})

		added[memberID] = true
	}

	if err := s.chats.Create(ctx, &chat, members); err != nil {
		return domain.ChatView{}, false, err
	}

	view, err := s.chats.GetChatView(ctx, chat.ID, creatorID)
	if err != nil {
		return domain.ChatView{}, false, err
	}

	return *view, true, nil
}

func (s *ChatService) List(ctx context.Context, userID uuid.UUID, limit int) ([]domain.ChatView, error) {
	views, err := s.chats.ListChats(ctx, userID, limit)
	if err != nil {
		return nil, err
	}

	for i := range views {
		unreadCount, err := s.chats.UnreadCount(ctx, views[i].Chat.ID, userID)
		if err == nil {
			views[i].UnreadCount = unreadCount
		}
	}

	return views, nil
}

func (s *ChatService) Get(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) (domain.ChatView, error) {
	view, err := s.chats.GetChatView(ctx, chatID, userID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return domain.ChatView{}, ErrChatNotFound
		}

		return domain.ChatView{}, err
	}

	if !view.IsMember {
		return domain.ChatView{}, ErrChatNotFound
	}

	unreadCount, err := s.chats.UnreadCount(ctx, chatID, userID)
	if err == nil {
		view.UnreadCount = unreadCount
	}

	return *view, nil
}

func (s *ChatService) Update(ctx context.Context, chatID uuid.UUID, userID uuid.UUID, input UpdateChatInput) (domain.ChatView, error) {
	view, err := s.chats.GetChatView(ctx, chatID, userID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return domain.ChatView{}, ErrChatNotFound
		}

		return domain.ChatView{}, err
	}

	if !view.IsMember {
		return domain.ChatView{}, ErrChatNotFound
	}

	if !canEditChatInfo(*view) {
		return domain.ChatView{}, ErrForbidden
	}

	if input.Title != nil && view.Chat.Type != domain.ChatTypePrivate {
		title := normalizeOptionalString(input.Title)
		if title == nil {
			return domain.ChatView{}, ErrTitleRequired
		}

		view.Chat.Title = title
	}

	if input.Description != nil {
		view.Chat.Description = normalizeOptionalString(input.Description)
	}

	if input.Theme != nil {
		view.Chat.Theme = normalizeOptionalString(input.Theme)
	}

	if err := s.chats.UpdateChat(ctx, &view.Chat); err != nil {
		return domain.ChatView{}, err
	}

	updatedView, err := s.chats.GetChatView(ctx, chatID, userID)
	if err != nil {
		return domain.ChatView{}, err
	}

	return *updatedView, nil
}

func (s *ChatService) Delete(ctx context.Context, chatID uuid.UUID, userID uuid.UUID) error {
	view, err := s.chats.GetChatView(ctx, chatID, userID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return ErrChatNotFound
		}

		return err
	}

	if !view.IsMember {
		return ErrChatNotFound
	}

	if !canDeleteChat(*view) {
		return ErrForbidden
	}

	return s.chats.Delete(ctx, chatID)
}

func canEditChatInfo(view domain.ChatView) bool {
	if !view.IsMember {
		return false
	}

	if view.Chat.Type == domain.ChatTypePrivate {
		return true
	}

	if view.Chat.AllowMemberEditInfo {
		return true
	}

	return view.MyRole == domain.ChatMemberRoleOwner || view.MyRole == domain.ChatMemberRoleAdmin
}

func canDeleteChat(view domain.ChatView) bool {
	if !view.IsMember {
		return false
	}

	if view.Chat.Type == domain.ChatTypePrivate {
		return true
	}

	return view.MyRole == domain.ChatMemberRoleOwner
}
