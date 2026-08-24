package handlers

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/pkg/unixtime"
	"supernova/internal/service"
)

type MuteHandler struct {
	mutes *service.MuteService
}

func NewMuteHandler(mutes *service.MuteService) *MuteHandler {
	return &MuteHandler{
		mutes: mutes,
	}
}

func (h *MuteHandler) Mute(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	chatID, err := uuidParam(r, "chatID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid chat id")
		return
	}

	var req dto.MuteChatRequest

	err = json.NewDecoder(r.Body).Decode(&req)
	if err != nil && !errors.Is(err, io.EOF) {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	if err := h.mutes.Mute(r.Context(), meID, chatID, req.DurationSeconds); err != nil {
		writeMuteError(w, r, err)
		return
	}

	response.OK(w, r, map[string]bool{
		"muted": true,
	})
}

func (h *MuteHandler) Unmute(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	chatID, err := uuidParam(r, "chatID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid chat id")
		return
	}

	if err := h.mutes.Unmute(r.Context(), meID, chatID); err != nil {
		writeMuteError(w, r, err)
		return
	}

	response.OK(w, r, map[string]bool{
		"muted": false,
	})
}

func (h *MuteHandler) Status(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	chatID, err := uuidParam(r, "chatID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid chat id")
		return
	}

	muted, mutedUntil, err := h.mutes.Status(r.Context(), meID, chatID)
	if err != nil {
		writeMuteError(w, r, err)
		return
	}

	response.OK(w, r, dto.MuteStatusResponse{
		Muted:      muted,
		MutedUntil: unixtime.NewPtr(mutedUntil),
	})
}

func writeMuteError(w http.ResponseWriter, r *http.Request, err error) {
	if errors.Is(err, service.ErrChatNotFound) {
		response.NotFound(w, r, "chat not found")
		return
	}

	response.Internal(w, r)
}
