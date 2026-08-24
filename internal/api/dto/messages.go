package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type CreateMessageRequest struct {
	Text          string     `json:"text"`
	AttachmentID  *uuid.UUID `json:"attachment_id"`
	AttachmentURL *string    `json:"attachment_url"`
	Kind          *string    `json:"kind"`
	ReplyToID     *uuid.UUID `json:"reply_to_id"`
}

type UpdateMessageRequest struct {
	Text string `json:"text"`
}

type MarkReadRequest struct {
	LastMessageID uuid.UUID `json:"last_message_id"`
}

type MessageResponse struct {
	ID              uuid.UUID                          `json:"id"`
	ChatID          uuid.UUID                          `json:"chat_id"`
	Sender          *UserMiniResponse                  `json:"sender"`
	Kind            string                             `json:"kind"`
	Text            *string                            `json:"text"`
	Attachment      *AttachmentResponse                `json:"attachment"`
	AttachmentURL   *string                            `json:"attachment_url"`
	ReplyToID       *uuid.UUID                         `json:"reply_to_id"`
	ForwardedFromID *uuid.UUID                         `json:"forwarded_from_id"`
	IsEdited        bool                               `json:"is_edited"`
	IsDeleted       bool                               `json:"is_deleted"`
	IsPinned        bool                               `json:"is_pinned"`
	Reactions       []ReactionSummaryWithUsersResponse `json:"reactions"`
	CreatedAt       unixtime.UnixTime                  `json:"created_at"`
	UpdatedAt       unixtime.UnixTime                  `json:"updated_at"`
	DeletedAt       *unixtime.UnixTime                 `json:"deleted_at"`
}

func NewMessageResponseWith(
	message domain.Message,
	sender *UserMiniResponse,
	reactions []ReactionSummaryWithUsersResponse,
	attachment *AttachmentResponse,
) MessageResponse {
	var text *string
	var attachmentURL *string

	if !message.IsDeleted {
		text = message.Text
		attachmentURL = message.AttachmentURL
	}

	if reactions == nil {
		reactions = []ReactionSummaryWithUsersResponse{}
	}

	return MessageResponse{
		ID:              message.ID,
		ChatID:          message.ChatID,
		Sender:          sender,
		Kind:            string(message.Kind),
		Text:            text,
		Attachment:      attachment,
		AttachmentURL:   attachmentURL,
		ReplyToID:       message.ReplyToID,
		ForwardedFromID: message.ForwardedFromID,
		IsEdited:        message.IsEdited,
		IsDeleted:       message.IsDeleted,
		IsPinned:        message.IsPinned,
		Reactions:       reactions,
		CreatedAt:       unixtime.New(message.CreatedAt),
		UpdatedAt:       unixtime.New(message.UpdatedAt),
		DeletedAt:       unixtime.NewPtr(message.DeletedAt),
	}
}

func NewMessageResponse(message domain.Message) MessageResponse {
	return NewMessageResponseWith(message, nil, nil, nil)
}
