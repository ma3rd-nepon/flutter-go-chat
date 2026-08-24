package cursor

import (
	"encoding/base64"
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
)

var ErrInvalidCursor = errors.New("invalid cursor")

type Cursor struct {
	Time time.Time `json:"t"`
	ID   uuid.UUID `json:"id"`
}

func Encode(t time.Time, id uuid.UUID) string {
	data, err := json.Marshal(Cursor{
		Time: t,
		ID:   id,
	})

	if err != nil {
		return ""
	}

	return base64.RawURLEncoding.EncodeToString(data)
}

func Decode(raw string) (*Cursor, error) {
	if raw == "" {
		return nil, nil
	}

	data, err := base64.RawURLEncoding.DecodeString(raw)
	if err != nil {
		return nil, ErrInvalidCursor
	}

	var cursor Cursor

	if err := json.Unmarshal(data, &cursor); err != nil {
		return nil, ErrInvalidCursor
	}

	return &cursor, nil
}
