package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type SessionResponse struct {
	ID        uuid.UUID         `json:"id"`
	UserAgent *string           `json:"user_agent"`
	IP        *string           `json:"ip"`
	ExpiresAt unixtime.UnixTime `json:"expires_at"`
	CreatedAt unixtime.UnixTime `json:"created_at"`
}

type RevokeSessionRequest struct {
	SessionID uuid.UUID `json:"session_id"`
}

func NewSessionResponse(session domain.RefreshToken) SessionResponse {
	return SessionResponse{
		ID:        session.ID,
		UserAgent: session.UserAgent,
		IP:        session.IP,
		ExpiresAt: unixtime.New(session.ExpiresAt),
		CreatedAt: unixtime.New(session.CreatedAt),
	}
}
