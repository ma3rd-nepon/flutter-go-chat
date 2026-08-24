package ws

import (
	"encoding/json"
	"sync"

	"github.com/google/uuid"
)

type Hub struct {
	mu      sync.RWMutex
	clients map[uuid.UUID]map[*Client]struct{}

	OnConnect    func(userID uuid.UUID)
	OnDisconnect func(userID uuid.UUID)
}

func NewHub() *Hub {
	return &Hub{
		clients: make(map[uuid.UUID]map[*Client]struct{}),
	}
}

func (h *Hub) Register(client *Client) {
	h.mu.Lock()

	connections, ok := h.clients[client.UserID]
	if !ok {
		connections = make(map[*Client]struct{})
		h.clients[client.UserID] = connections
	}

	first := len(connections) == 0
	connections[client] = struct{}{}

	h.mu.Unlock()

	if first && h.OnConnect != nil {
		h.OnConnect(client.UserID)
	}
}

func (h *Hub) Unregister(client *Client) {
	h.mu.Lock()

	connections, ok := h.clients[client.UserID]
	if !ok {
		h.mu.Unlock()
		return
	}

	if _, ok := connections[client]; !ok {
		h.mu.Unlock()
		return
	}

	delete(connections, client)
	close(client.Send)

	last := len(connections) == 0
	if last {
		delete(h.clients, client.UserID)
	}

	h.mu.Unlock()

	if last && h.OnDisconnect != nil {
		h.OnDisconnect(client.UserID)
	}
}

func (h *Hub) BroadcastToUser(userID uuid.UUID, event Event) {
	payload, err := json.Marshal(event)
	if err != nil {
		return
	}

	h.sendBytes(userID, payload)
}

func (h *Hub) BroadcastToUsers(userIDs []uuid.UUID, event Event, exceptUserID *uuid.UUID) {
	payload, err := json.Marshal(event)
	if err != nil {
		return
	}

	for _, userID := range userIDs {
		if exceptUserID != nil && userID == *exceptUserID {
			continue
		}

		h.sendBytes(userID, payload)
	}
}

func (h *Hub) sendBytes(userID uuid.UUID, payload []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	connections, ok := h.clients[userID]
	if !ok {
		return
	}

	for client := range connections {
		select {
		case client.Send <- payload:
		default:
		}
	}
}
