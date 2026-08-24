package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/google/uuid"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/pkg/unixtime"
	"supernova/internal/service"
	"supernova/internal/ws"
)

type VoiceHandler struct {
	voice  *service.VoiceService
	events *service.EventService
}

func NewVoiceHandler(voice *service.VoiceService, events *service.EventService) *VoiceHandler {
	return &VoiceHandler{
		voice:  voice,
		events: events,
	}
}

func (h *VoiceHandler) Create(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	var req dto.CreateVoiceChannelRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if req.ChatID == uuid.Nil {
		response.BadRequest(w, r, "validation_error", "chat_id is required")
		return
	}

	input := service.CreateVoiceChannelInput{
		ChatID:          req.ChatID,
		Name:            req.Name,
		Bitrate:         req.Bitrate,
		MaxParticipants: req.MaxParticipants,
	}

	channel, err := h.voice.Create(r.Context(), meID, input)
	if err != nil {
		writeVoiceError(w, r, err)
		return
	}

	response.Created(w, r, dto.NewVoiceChannelResponse(channel, nil))
}

func (h *VoiceHandler) Get(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	channelID, err := uuidParam(r, "channelID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid channel id")
		return
	}

	view, err := h.voice.Get(r.Context(), meID, channelID)
	if err != nil {
		writeVoiceError(w, r, err)
		return
	}

	response.OK(w, r, dto.NewVoiceChannelResponse(view.Channel, view.Participants))
}

func (h *VoiceHandler) Join(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	channelID, err := uuidParam(r, "channelID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid channel id")
		return
	}

	result, err := h.voice.Join(r.Context(), meID, channelID)
	if err != nil {
		writeVoiceError(w, r, err)
		return
	}

	rtcToken := "rtc_" + uuid.NewString()

	h.events.BroadcastChatEvent(
		r.Context(),
		result.ChatID,
		nil,
		ws.NewEvent(ws.EventVoiceStateUpdate, &result.ChatID, map[string]any{
			"channel_id": result.ChannelID.String(),
			"user_id":    meID.String(),
			"action":     "join",
			"joined_at":  result.JoinedAt.Unix(),
		}),
	)

	response.OK(w, r, dto.JoinVoiceResponse{
		ChannelID: result.ChannelID,
		Joined:    true,
		RTCToken:  rtcToken,
		JoinedAt:  unixtime.New(result.JoinedAt),
	})
}

func (h *VoiceHandler) Leave(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	channelID, err := uuidParam(r, "channelID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid channel id")
		return
	}

	chatID, err := h.voice.Leave(r.Context(), meID, channelID)
	if err != nil {
		writeVoiceError(w, r, err)
		return
	}

	h.events.BroadcastChatEvent(
		r.Context(),
		chatID,
		nil,
		ws.NewEvent(ws.EventVoiceStateUpdate, &chatID, map[string]any{
			"channel_id": channelID.String(),
			"user_id":    meID.String(),
			"action":     "leave",
		}),
	)

	response.OK(w, r, dto.LeaveVoiceResponse{
		ChannelID: channelID,
		Left:      true,
	})
}

func writeVoiceError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, service.ErrInvalidVoiceChannelName),
		errors.Is(err, service.ErrInvalidBitrate),
		errors.Is(err, service.ErrInvalidMaxParticipants):
		response.BadRequest(w, r, "validation_error", err.Error())
		return

	case errors.Is(err, service.ErrVoiceChannelFull):
		response.Conflict(w, r, err.Error())
		return

	case errors.Is(err, service.ErrVoiceChannelNotFound),
		errors.Is(err, service.ErrChatNotFound):
		response.NotFound(w, r, "not found")
		return

	case errors.Is(err, service.ErrForbidden):
		response.Forbidden(w, r, "forbidden")
		return

	default:
		response.Internal(w, r)
		return
	}
}
