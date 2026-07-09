package hub

import (
	"encoding/json"
	"log/slog"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

type Client struct {
	Hub           *Hub
	Conn          *websocket.Conn
	UserID        string
	Username      string
	Send          chan []byte
	subscriptions map[string]bool
	mu            sync.RWMutex
}

func (c *Client) Subscribe(chatID string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.subscriptions == nil {
		c.subscriptions = make(map[string]bool)
	}
	c.subscriptions[chatID] = true
}

func (c *Client) IsSubscribed(chatID string) bool {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.subscriptions[chatID]
}

type Hub struct {
	clients     map[*Client]bool
	Broadcast   chan []byte
	Register    chan *Client
	Unregister  chan *Client
	onlineUsers map[string]bool
	mu          sync.RWMutex
}

type WebSocketMessage struct {
	Type      string          `json:"type"`
	Payload   json.RawMessage `json:"payload"`
	Timestamp string          `json:"timestamp"`
}

func NewHub() *Hub {
	return &Hub{
		clients:     make(map[*Client]bool),
		Broadcast:   make(chan []byte, 256),
		Register:    make(chan *Client),
		Unregister:  make(chan *Client),
		onlineUsers: make(map[string]bool),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.Register:
			h.mu.Lock()
			h.clients[client] = true
			h.mu.Unlock()

		case client := <-h.Unregister:
			h.mu.Lock()
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				close(client.Send)
			}
			h.mu.Unlock()

		case message := <-h.Broadcast:
			h.mu.RLock()
			for client := range h.clients {
				select {
				case client.Send <- message:
				default:
					close(client.Send)
					delete(h.clients, client)
				}
			}
			h.mu.RUnlock()
		}
	}
}

func (h *Hub) SetUserOnline(userID string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.onlineUsers[userID] = true
	slog.Info("Пользователь онлайн", "user_id", userID, "total_online", len(h.onlineUsers))
}

func (h *Hub) SetUserOffline(userID string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	delete(h.onlineUsers, userID)
	slog.Info("Пользователь оффлайн", "user_id", userID, "total_online", len(h.onlineUsers))
}

func (h *Hub) IsUserOnline(userID string) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	online := h.onlineUsers[userID]
	return online
}

func (h *Hub) BroadcastToAll(message []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()
	for client := range h.clients {
		select {
		case client.Send <- message:
		default:
			close(client.Send)
			delete(h.clients, client)
		}
	}
}

func (h *Hub) BroadcastToChat(chatID string, message []byte, excludeUserID string) {
	h.mu.RLock()
	defer h.mu.RUnlock()
	for client := range h.clients {
		if client.UserID == excludeUserID {
			continue
		}
		if !client.IsSubscribed(chatID) {
			continue
		}
		select {
		case client.Send <- message:
		default:
			close(client.Send)
			delete(h.clients, client)
		}
	}
}

func (h *Hub) BroadcastOnlineStatus(userID string, isOnline bool) {
	payload, _ := json.Marshal(map[string]interface{}{
		"user_id":   userID,
		"is_online": isOnline,
		"timestamp": time.Now().Format(time.RFC3339),
	})

	message, _ := json.Marshal(WebSocketMessage{
		Type:      "online_status",
		Payload:   payload,
		Timestamp: time.Now().Format(time.RFC3339),
	})

	h.BroadcastToAll(message)
}
