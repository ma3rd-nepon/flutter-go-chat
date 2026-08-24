package service

import (
	"context"
	"errors"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/repository"
)

var (
	ErrVoiceChannelNotFound    = errors.New("voice channel not found")
	ErrInvalidVoiceChannelName = errors.New("invalid voice channel name")
	ErrInvalidBitrate          = errors.New("invalid bitrate")
	ErrInvalidMaxParticipants  = errors.New("invalid max participants")
	ErrVoiceChannelFull        = errors.New("voice channel is full")
)

type VoiceService struct {
	voice *repository.VoiceRepository
	chats *repository.ChatRepository
}

func NewVoiceService(
	voice *repository.VoiceRepository,
	chats *repository.ChatRepository,
) *VoiceService {
	return &VoiceService{
		voice: voice,
		chats: chats,
	}
}

type CreateVoiceChannelInput struct {
	ChatID          uuid.UUID
	Name            string
	Bitrate         *int
	MaxParticipants *int
}

type VoiceChannelView struct {
	Channel      domain.VoiceChannel
	Participants []domain.VoiceParticipant
}

type JoinVoiceResult struct {
	ChannelID uuid.UUID
	ChatID    uuid.UUID
	JoinedAt  time.Time
}

func (s *VoiceService) Create(ctx context.Context, actorID uuid.UUID, input CreateVoiceChannelInput) (domain.VoiceChannel, error) {
	view, err := s.chats.GetChatView(ctx, input.ChatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return domain.VoiceChannel{}, ErrChatNotFound
		}

		return domain.VoiceChannel{}, err
	}

	if !view.IsMember {
		return domain.VoiceChannel{}, ErrChatNotFound
	}

	name := normalizeOptionalString(&input.Name)
	if name == nil {
		return domain.VoiceChannel{}, ErrInvalidVoiceChannelName
	}

	bitrate := 64000
	if input.Bitrate != nil {
		bitrate = *input.Bitrate
	}

	if bitrate < 8000 || bitrate > 384000 {
		return domain.VoiceChannel{}, ErrInvalidBitrate
	}

	var maxParticipants *int

	if input.MaxParticipants != nil {
		if *input.MaxParticipants <= 0 {
			return domain.VoiceChannel{}, ErrInvalidMaxParticipants
		}

		maxParticipants = input.MaxParticipants
	}

	channel := domain.VoiceChannel{
		ID:              uuid.New(),
		ChatID:          input.ChatID,
		Name:            *name,
		Bitrate:         bitrate,
		MaxParticipants: maxParticipants,
	}

	if err := s.voice.Create(ctx, &channel); err != nil {
		return domain.VoiceChannel{}, err
	}

	return channel, nil
}

func (s *VoiceService) Get(ctx context.Context, actorID uuid.UUID, channelID uuid.UUID) (VoiceChannelView, error) {
	channel, err := s.voice.GetByID(ctx, channelID)
	if err != nil {
		if errors.Is(err, repository.ErrVoiceChannelNotFound) {
			return VoiceChannelView{}, ErrVoiceChannelNotFound
		}

		return VoiceChannelView{}, err
	}

	view, err := s.chats.GetChatView(ctx, channel.ChatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return VoiceChannelView{}, ErrChatNotFound
		}

		return VoiceChannelView{}, err
	}

	if !view.IsMember {
		return VoiceChannelView{}, ErrChatNotFound
	}

	participants, err := s.voice.ListParticipants(ctx, channelID)
	if err != nil {
		return VoiceChannelView{}, err
	}

	return VoiceChannelView{
		Channel:      *channel,
		Participants: participants,
	}, nil
}

func (s *VoiceService) Join(ctx context.Context, actorID uuid.UUID, channelID uuid.UUID) (JoinVoiceResult, error) {
	channel, err := s.voice.GetByID(ctx, channelID)
	if err != nil {
		if errors.Is(err, repository.ErrVoiceChannelNotFound) {
			return JoinVoiceResult{}, ErrVoiceChannelNotFound
		}

		return JoinVoiceResult{}, err
	}

	view, err := s.chats.GetChatView(ctx, channel.ChatID, actorID)
	if err != nil {
		if errors.Is(err, repository.ErrChatNotFound) {
			return JoinVoiceResult{}, ErrChatNotFound
		}

		return JoinVoiceResult{}, err
	}

	if !view.IsMember {
		return JoinVoiceResult{}, ErrChatNotFound
	}

	if channel.MaxParticipants != nil {
		isParticipant, err := s.voice.IsParticipant(ctx, channelID, actorID)
		if err != nil {
			return JoinVoiceResult{}, err
		}

		if !isParticipant {
			count, err := s.voice.CountParticipants(ctx, channelID)
			if err != nil {
				return JoinVoiceResult{}, err
			}

			if count >= *channel.MaxParticipants {
				return JoinVoiceResult{}, ErrVoiceChannelFull
			}
		}
	}

	now := time.Now().UTC()

	participant := domain.VoiceParticipant{
		ChannelID: channelID,
		UserID:    actorID,
		JoinedAt:  now,
		Muted:     false,
		Deafened:  false,
	}

	if err := s.voice.AddParticipant(ctx, participant); err != nil {
		return JoinVoiceResult{}, err
	}

	return JoinVoiceResult{
		ChannelID: channelID,
		ChatID:    channel.ChatID,
		JoinedAt:  now,
	}, nil
}

func (s *VoiceService) Leave(ctx context.Context, actorID uuid.UUID, channelID uuid.UUID) (uuid.UUID, error) {
	channel, err := s.voice.GetByID(ctx, channelID)
	if err != nil {
		if errors.Is(err, repository.ErrVoiceChannelNotFound) {
			return uuid.Nil, ErrVoiceChannelNotFound
		}

		return uuid.Nil, err
	}

	if err := s.voice.RemoveParticipant(ctx, channelID, actorID); err != nil {
		return uuid.Nil, err
	}

	return channel.ChatID, nil
}
