package service

import (
	"context"
	"errors"
	"mime/multipart"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/storage"
	"supernova/internal/repository"
)

var allowedImageExtensions = map[string]string{
	".png":  "image",
	".jpg":  "image",
	".jpeg": "image",
	".webp": "image",
	".gif":  "image",
}

var allowedAttachmentExtensions = map[string]string{
	".png":  "image",
	".jpg":  "image",
	".jpeg": "image",
	".webp": "image",
	".gif":  "image",

	".pdf": "file",
	".txt": "file",
	".zip": "file",
	".rar": "file",
	".7z":  "file",

	".mp3": "voice",
	".ogg": "voice",
	".wav": "voice",
	".m4a": "voice",

	".mp4":  "file",
	".mov":  "file",
	".webm": "file",
}

type UploadConfig struct {
	MaxAvatarSize     int64
	MaxBannerSize     int64
	MaxAttachmentSize int64
}

type AttachmentResult struct {
	ID        uuid.UUID
	URL       string
	Filename  string
	Kind      string
	MimeType  string
	SizeBytes int64
}

type UploadService struct {
	storage     *storage.LocalStorage
	users       *repository.UserRepository
	chats       *repository.ChatRepository
	attachments *repository.AttachmentRepository
	cfg         UploadConfig
}

func NewUploadService(
	storage *storage.LocalStorage,
	users *repository.UserRepository,
	chats *repository.ChatRepository,
	attachments *repository.AttachmentRepository,
	cfg UploadConfig,
) *UploadService {
	return &UploadService{
		storage:     storage,
		users:       users,
		chats:       chats,
		attachments: attachments,
		cfg:         cfg,
	}
}

func (s *UploadService) UploadAvatar(
	ctx context.Context,
	userID uuid.UUID,
	file multipart.File,
	header *multipart.FileHeader,
) (string, error) {
	url, _, _, _, _, err := s.storage.Save(
		"avatars",
		file,
		header,
		allowedImageExtensions,
		s.cfg.MaxAvatarSize,
	)

	if err != nil {
		return "", err
	}

	if err := s.users.SetAvatarURL(ctx, userID, url); err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return "", ErrUserNotFound
		}

		return "", err
	}

	return url, nil
}

func (s *UploadService) UploadBanner(
	ctx context.Context,
	userID uuid.UUID,
	file multipart.File,
	header *multipart.FileHeader,
) (string, error) {
	url, _, _, _, _, err := s.storage.Save(
		"banners",
		file,
		header,
		allowedImageExtensions,
		s.cfg.MaxBannerSize,
	)

	if err != nil {
		return "", err
	}

	if err := s.users.SetBannerURL(ctx, userID, url); err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return "", ErrUserNotFound
		}

		return "", err
	}

	return url, nil
}

func (s *UploadService) UploadChatAvatar(
	ctx context.Context,
	chatID uuid.UUID,
	actorID uuid.UUID,
	file multipart.File,
	header *multipart.FileHeader,
) (domain.ChatView, error) {
	view, err := s.chats.GetChatView(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return domain.ChatView{}, ErrChatNotFound
		}

		return domain.ChatView{}, err
	}

	if !view.IsMember {
		return domain.ChatView{}, ErrChatNotFound
	}

	if !canEditChatAvatar(*view) {
		return domain.ChatView{}, ErrForbidden
	}

	url, _, _, _, _, err := s.storage.Save(
		"chats",
		file,
		header,
		allowedImageExtensions,
		s.cfg.MaxAvatarSize,
	)

	if err != nil {
		return domain.ChatView{}, err
	}

	if err := s.chats.SetAvatarURL(ctx, chatID, url); err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return domain.ChatView{}, ErrChatNotFound
		}

		return domain.ChatView{}, err
	}

	updatedView, err := s.chats.GetChatView(ctx, chatID, actorID)
	if err != nil {
		return domain.ChatView{}, err
	}

	return *updatedView, nil
}

func (s *UploadService) UploadAttachment(
	ctx context.Context,
	chatID uuid.UUID,
	actorID uuid.UUID,
	file multipart.File,
	header *multipart.FileHeader,
) (AttachmentResult, error) {
	view, err := s.chats.GetChatView(ctx, chatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return AttachmentResult{}, ErrChatNotFound
		}

		return AttachmentResult{}, err
	}

	if !view.IsMember {
		return AttachmentResult{}, ErrChatNotFound
	}

	if !canSendMessage(*view) {
		return AttachmentResult{}, ErrForbidden
	}

	url, originalFilename, kind, mimeType, sizeBytes, err := s.storage.Save(
		"attachments",
		file,
		header,
		allowedAttachmentExtensions,
		s.cfg.MaxAttachmentSize,
	)

	if err != nil {
		return AttachmentResult{}, err
	}

	attachment := domain.Attachment{
		ID:         uuid.New(),
		ChatID:     chatID,
		UploaderID: &actorID,
		URL:        url,
		Filename:   originalFilename,
		MimeType:   mimeType,
		SizeBytes:  sizeBytes,
		Kind:       domain.MessageKind(kind),
	}

	if err := s.attachments.Create(ctx, &attachment); err != nil {
		return AttachmentResult{}, err
	}

	return AttachmentResult{
		ID:        attachment.ID,
		URL:       url,
		Filename:  originalFilename,
		Kind:      kind,
		MimeType:  mimeType,
		SizeBytes: sizeBytes,
	}, nil
}

func canEditChatAvatar(view domain.ChatView) bool {
	if view.Chat.Type == domain.ChatTypePrivate {
		return true
	}

	if view.Chat.AllowMemberEditInfo {
		return true
	}

	return view.MyRole == domain.ChatMemberRoleOwner || view.MyRole == domain.ChatMemberRoleAdmin
}

func canSendMessage(view domain.ChatView) bool {
	if view.Chat.AllowMemberSendMessages {
		return true
	}

	return view.MyRole == domain.ChatMemberRoleOwner || view.MyRole == domain.ChatMemberRoleAdmin
}
