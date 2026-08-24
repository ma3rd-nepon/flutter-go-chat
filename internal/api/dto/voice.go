package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type CreateVoiceChannelRequest struct {
	ChatID          uuid.UUID `json:"chat_id"`
	Name            string    `json:"name"`
	Bitrate         *int      `json:"bitrate"`
	MaxParticipants *int      `json:"max_participants"`
}

type VoiceParticipantResponse struct {
	UserID   uuid.UUID         `json:"user_id"`
	JoinedAt unixtime.UnixTime `json:"joined_at"`
	Muted    bool              `json:"muted"`
	Deafened bool              `json:"deafened"`
}

type VoiceChannelResponse struct {
	ID               uuid.UUID                  `json:"id"`
	ChatID           uuid.UUID                  `json:"chat_id"`
	Name             string                     `json:"name"`
	Bitrate          int                        `json:"bitrate"`
	MaxParticipants  *int                       `json:"max_participants"`
	ParticipantCount int                        `json:"participant_count"`
	Participants     []VoiceParticipantResponse `json:"participants"`
	CreatedAt        unixtime.UnixTime          `json:"created_at"`
	UpdatedAt        unixtime.UnixTime          `json:"updated_at"`
}

type JoinVoiceResponse struct {
	ChannelID uuid.UUID         `json:"channel_id"`
	Joined    bool              `json:"joined"`
	RTCToken  string            `json:"rtc_token"`
	JoinedAt  unixtime.UnixTime `json:"joined_at"`
}

type LeaveVoiceResponse struct {
	ChannelID uuid.UUID `json:"channel_id"`
	Left      bool      `json:"left"`
}

func NewVoiceChannelResponse(channel domain.VoiceChannel, participants []domain.VoiceParticipant) VoiceChannelResponse {
	items := make([]VoiceParticipantResponse, 0, len(participants))

	for _, participant := range participants {
		items = append(items, VoiceParticipantResponse{
			UserID:   participant.UserID,
			JoinedAt: unixtime.New(participant.JoinedAt),
			Muted:    participant.Muted,
			Deafened: participant.Deafened,
		})
	}

	return VoiceChannelResponse{
		ID:               channel.ID,
		ChatID:           channel.ChatID,
		Name:             channel.Name,
		Bitrate:          channel.Bitrate,
		MaxParticipants:  channel.MaxParticipants,
		ParticipantCount: len(items),
		Participants:     items,
		CreatedAt:        unixtime.New(channel.CreatedAt),
		UpdatedAt:        unixtime.New(channel.UpdatedAt),
	}
}
