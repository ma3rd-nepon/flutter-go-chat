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
	ErrMessageNotFound    = errors.New("message not found")
	ErrEmptyMessage       = errors.New("message text is required")
	ErrInvalidReply       = errors.New("invalid reply message")
	ErrInvalidAttachment  = errors.New("invalid attachment")
	ErrInvalidMessageKind = errors.New("invalid message kind")
	ErrRestricted         = errors.New("you are restricted from sending messages in this chat")
)

type MessageService struct {
	messages    *repository.MessageRepository
	chats       *repository.ChatRepository
	attachments *repository.AttachmentRepository
}

func NewMessageService(
	messages *repository.MessageRepository,
	chats *repository.ChatRepository,
	attachments *repository.AttachmentRepository,
) *MessageService {
	return &MessageService{
		messages:    messages,
		chats:       chats,
		attachments: attachments,
	}
}

type CreateMessageInput struct {
	Text          *string
	AttachmentID  *uuid.UUID
	AttachmentURL *string
	Kind          *string
	ReplyToID     *uuid.UUID
}

type UpdateMessageInput struct {
	Text *string
}

func (s *MessageService) List(ctx context.Context, chatID uuid.UUID, userID uuid.UUID, limit int) ([]domain.Message, error) {
	view, err := s.chats.GetChatView(ctx, chatID, userID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return nil, ErrChatNotFound
		}

		return nil, err
	}

	if !view.IsMember {
		return nil, ErrChatNotFound
	}

	return s.messages.ListByChat(ctx, chatID, limit)
}

func (s *MessageService) Create(ctx context.Context, chatID uuid.UUID, senderID uuid.UUID, input CreateMessageInput) (domain.Message, error) {
	view, err := s.chats.GetChatView(ctx, chatID, senderID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return domain.Message{}, ErrChatNotFound
		}

		return domain.Message{}, err
	}

	if !view.IsMember {
		return domain.Message{}, ErrChatNotFound
	}

	if !view.Chat.AllowMemberSendMessages &&
		view.MyRole != domain.ChatMemberRoleOwner &&
		view.MyRole != domain.ChatMemberRoleAdmin {
		return domain.Message{}, ErrForbidden
	}

	if view.MyRole == domain.ChatMemberRoleMember {
		restricted, err := s.chats.IsRestricted(ctx, chatID, senderID)
		if err != nil {
			return domain.Message{}, err
		}

		if restricted {
			return domain.Message{}, ErrRestricted
		}
	}

	text := normalizeOptionalString(input.Text)

	var attachmentID *uuid.UUID
	var attachmentURL *string
	kind := domain.MessageKindText

	switch {
	case input.AttachmentID != nil:
		att, err := s.attachments.GetByID(ctx, *input.AttachmentID)
		if err != nil {
			if errors.Is(err, repository.ErrAttachmentNotFound) {
				return domain.Message{}, ErrInvalidAttachment
			}

			return domain.Message{}, err
		}

		if att.ChatID != chatID {
			return domain.Message{}, ErrInvalidAttachment
		}

		attachmentID = &att.ID
		attachmentURL = &att.URL
		kind = att.Kind

	case func() bool { attachmentURL = normalizeOptionalString(input.AttachmentURL); return attachmentURL != nil }():
		if !strings.HasPrefix(*attachmentURL, "/uploads/attachments/") {
			return domain.Message{}, ErrInvalidAttachment
		}

		kind = domain.MessageKindFile

		if input.Kind != nil {
			normalizedKind := strings.ToLower(strings.TrimSpace(*input.Kind))
			if normalizedKind == "video" {
				normalizedKind = "file"
			}

			switch domain.MessageKind(normalizedKind) {
			case domain.MessageKindImage,
				domain.MessageKindFile,
				domain.MessageKindVoice:
				kind = domain.MessageKind(normalizedKind)
			default:
				return domain.Message{}, ErrInvalidMessageKind
			}
		}

	default:
		if input.Kind != nil {
			normalizedKind := strings.ToLower(strings.TrimSpace(*input.Kind))

			if normalizedKind != "" && normalizedKind != "text" {
				return domain.Message{}, ErrInvalidMessageKind
			}
		}
	}

	if text == nil && attachmentURL == nil {
		return domain.Message{}, ErrEmptyMessage
	}

	if input.ReplyToID != nil {
		replyMessage, err := s.messages.GetByID(ctx, *input.ReplyToID)
		if err != nil {
			if errors.Is(err, repository.ErrMessageNotFound) {
				return domain.Message{}, ErrInvalidReply
			}

			return domain.Message{}, err
		}

		if replyMessage.ChatID != chatID || replyMessage.IsDeleted {
			return domain.Message{}, ErrInvalidReply
		}
	}

	now := time.Now().UTC()

	message := domain.Message{
		ID:            uuid.New(),
		ChatID:        chatID,
		SenderID:      &senderID,
		Kind:          kind,
		Text:          text,
		AttachmentURL: attachmentURL,
		AttachmentID:  attachmentID,
		ReplyToID:     input.ReplyToID,

		IsEdited:  false,
		IsDeleted: false,
		IsPinned:  false,

		CreatedAt: now,
		UpdatedAt: now,
	}

	if err := s.messages.Create(ctx, &message); err != nil {
		return domain.Message{}, err
	}

	return message, nil
}

func (s *MessageService) Update(ctx context.Context, messageID uuid.UUID, editorID uuid.UUID, input UpdateMessageInput) (domain.Message, error) {
	message, err := s.messages.GetByID(ctx, messageID)
	if err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return domain.Message{}, ErrMessageNotFound
		}

		return domain.Message{}, err
	}

	if message.IsDeleted {
		return domain.Message{}, ErrMessageNotFound
	}

	if message.SenderID == nil || *message.SenderID != editorID {
		return domain.Message{}, ErrForbidden
	}

	text := normalizeOptionalString(input.Text)
	if text == nil {
		return domain.Message{}, ErrEmptyMessage
	}

	if err := s.messages.UpdateText(ctx, messageID, *text); err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return domain.Message{}, ErrMessageNotFound
		}

		return domain.Message{}, err
	}

	message.Text = text
	message.IsEdited = true
	message.UpdatedAt = time.Now().UTC()

	return *message, nil
}

func (s *MessageService) Delete(ctx context.Context, messageID uuid.UUID, actorID uuid.UUID) (domain.Message, error) {
	message, err := s.messages.GetByID(ctx, messageID)
	if err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return domain.Message{}, ErrMessageNotFound
		}

		return domain.Message{}, err
	}

	if message.IsDeleted {
		return domain.Message{}, ErrMessageNotFound
	}

	view, err := s.chats.GetChatView(ctx, message.ChatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return domain.Message{}, ErrChatNotFound
		}

		return domain.Message{}, err
	}

	if !view.IsMember {
		return domain.Message{}, ErrChatNotFound
	}

	isSender := message.SenderID != nil && *message.SenderID == actorID
	isPrivileged := view.MyRole == domain.ChatMemberRoleOwner || view.MyRole == domain.ChatMemberRoleAdmin

	if !isSender && !isPrivileged {
		return domain.Message{}, ErrForbidden
	}

	if err := s.messages.SoftDelete(ctx, messageID); err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return domain.Message{}, ErrMessageNotFound
		}

		return domain.Message{}, err
	}

	now := time.Now().UTC()

	message.IsDeleted = true
	message.DeletedAt = &now
	message.UpdatedAt = now

	return *message, nil
}

func (s *MessageService) MarkRead(ctx context.Context, chatID uuid.UUID, userID uuid.UUID, messageID uuid.UUID) error {
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

	err = s.messages.MarkRead(ctx, chatID, userID, messageID)
	if err != nil {
		if errors.Is(err, repository.ErrMessageNotFound) {
			return ErrMessageNotFound
		}

		return err
	}

	return nil
}
