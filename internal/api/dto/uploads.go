package dto

import (
	"github.com/google/uuid"
)

type UploadResponse struct {
	URL string `json:"url"`
}

type AttachmentUploadResponse struct {
	ID        uuid.UUID `json:"id"`
	URL       string    `json:"url"`
	Filename  string    `json:"filename"`
	MimeType  string    `json:"mime_type"`
	SizeBytes int64     `json:"size_bytes"`
	Kind      string    `json:"kind"`
}
