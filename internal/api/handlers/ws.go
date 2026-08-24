package handlers

import (
	"context"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"supernova/internal/api/response"
	appjwt "supernova/internal/pkg/jwt"
	"supernova/internal/service"
	"supernova/internal/ws"
)

type WSHandler struct {
	hub      *ws.Hub
	jwt      *appjwt.Service
	events   *service.EventService
	upgrader websocket.Upgrader
}

func NewWSHandler(hub *ws.Hub, jwtService *appjwt.Service, events *service.EventService) *WSHandler {
	return &WSHandler{
		hub:    hub,
		jwt:    jwtService,
		events: events,
		upgrader: websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
			CheckOrigin: func(r *http.Request) bool {
				return true
			},
		},
	}
}

func (h *WSHandler) Handle(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		response.Unauthorized(w, r, "token is required")
		return
	}

	claims, err := h.jwt.ParseAccessToken(token)
	if err != nil {
		response.Unauthorized(w, r, "invalid or expired token")
		return
	}

	conn, err := h.upgrader.Upgrade(w, r, nil)
	if err != nil {
		return
	}

	client := &ws.Client{
		Hub:    h.hub,
		UserID: claims.UserID,
		Conn:   conn,
		Send:   make(chan []byte, 256),
	}

	client.Handler = h.handleClientEvent

	h.hub.Register(client)

	h.hub.BroadcastToUser(
		claims.UserID,
		ws.NewEvent(ws.EventConnected, nil, map[string]any{
			"user_id": claims.UserID.String(),
		}),
	)

	go client.WritePump()
	go client.ReadPump()
}

func (h *WSHandler) handleClientEvent(userID uuid.UUID, event ws.Event) {
	switch event.Event {
	case ws.EventTypingStart, ws.EventTypingStop:
		if event.ChatID == nil {
			return
		}

		chatID := *event.ChatID

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		outgoingEvent := ws.NewEvent(event.Event, &chatID, map[string]any{
			"user_id": userID.String(),
			"chat_id": chatID.String(),
		})

		h.events.BroadcastChatEventIfMember(ctx, chatID, userID, &userID, outgoingEvent)
	}
}
