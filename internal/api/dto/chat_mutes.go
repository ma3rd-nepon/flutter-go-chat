package dto

import (
	"supernova/internal/pkg/unixtime"
)

type MuteChatRequest struct {
	DurationSeconds *int `json:"duration_seconds"`
}

type MuteStatusResponse struct {
	Muted      bool               `json:"muted"`
	MutedUntil *unixtime.UnixTime `json:"muted_until"`
}
