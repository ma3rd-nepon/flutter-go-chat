package domain

import (
	"time"

	"github.com/google/uuid"
)

type Attachment struct {
	ID         uuid.UUID
	ChatID     uuid.UUID
	UploaderID *uuid.UUID
	URL        string
	Filename   string
	MimeType   string
	SizeBytes  int64
	Kind       MessageKind
	Width      *int
	Height     *int
	CreatedAt  time.Time
}
