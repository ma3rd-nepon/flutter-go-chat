package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type AttachmentResponse struct {
	ID        uuid.UUID         `json:"id"`
	URL       string            `json:"url"`
	Filename  string            `json:"filename"`
	MimeType  string            `json:"mime_type"`
	SizeBytes int64             `json:"size_bytes"`
	Kind      string            `json:"kind"`
	Width     *int              `json:"width"`
	Height    *int              `json:"height"`
	CreatedAt unixtime.UnixTime `json:"created_at"`
}

func NewAttachmentResponse(a domain.Attachment) AttachmentResponse {
	return AttachmentResponse{
		ID:        a.ID,
		URL:       a.URL,
		Filename:  a.Filename,
		MimeType:  a.MimeType,
		SizeBytes: a.SizeBytes,
		Kind:      string(a.Kind),
		Width:     a.Width,
		Height:    a.Height,
		CreatedAt: unixtime.New(a.CreatedAt),
	}
}
