package handlers

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/go-chi/chi/v5"

	"supernova/internal/api/dto"
	"supernova/internal/api/middleware"
	"supernova/internal/api/response"
	"supernova/internal/service"
	"supernova/internal/ws"
)

type ReactionHandler struct {
	reactions *service.ReactionService
	events    *service.EventService
}

func NewReactionHandler(reactions *service.ReactionService, events *service.EventService) *ReactionHandler {
	return &ReactionHandler{
		reactions: reactions,
		events:    events,
	}
}

func (h *ReactionHandler) Add(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	messageID, err := uuidParam(r, "messageID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid message id")
		return
	}

	var req dto.AddReactionRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.BadRequest(w, r, "validation_error", "invalid request body")
		return
	}

	result, added, err := h.reactions.Add(r.Context(), messageID, meID, req.Emoji)
	if err != nil {
		writeReactionError(w, r, err)
		return
	}

	reactionResponse := dto.NewReactionResponse(result.Reaction)
	chatID := result.ChatID

	h.events.BroadcastChatEvent(
		r.Context(),
		chatID,
		nil,
		ws.NewEvent(ws.EventReactionAdded, &chatID, map[string]any{
			"reaction": reactionResponse,
		}),
	)

	if added {
		response.Created(w, r, reactionResponse)
		return
	}

	response.OK(w, r, reactionResponse)
}

func (h *ReactionHandler) Remove(w http.ResponseWriter, r *http.Request) {
	meID, ok := middleware.UserIDFromContext(r.Context())
	if !ok {
		response.Unauthorized(w, r, "unauthorized")
		return
	}

	messageID, err := uuidParam(r, "messageID")
	if err != nil {
		response.BadRequest(w, r, "validation_error", "invalid message id")
		return
	}

	emoji := chi.URLParam(r, "emoji")

	chatID, normalizedEmoji, err := h.reactions.Remove(r.Context(), messageID, meID, emoji)
	if err != nil {
		writeReactionError(w, r, err)
		return
	}

	h.events.BroadcastChatEvent(
		r.Context(),
		chatID,
		nil,
		ws.NewEvent(ws.EventReactionRemoved, &chatID, map[string]any{
			"message_id": messageID,
			"user_id":    meID,
			"emoji":      normalizedEmoji,
		}),
	)

	response.OK(w, r, map[string]bool{
		"removed": true,
	})
}

func writeReactionError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, service.ErrInvalidEmoji):
		response.BadRequest(w, r, "validation_error", err.Error())
		return

	case errors.Is(err, service.ErrMessageNotFound),
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
