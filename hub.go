package hub

import (
	"sync"

	"github.com/gorilla/websocket"
)

type Client struct {
	Hub      *Hub
	Conn     *websocket.Conn
	UserID   string
	Username string
	Send     chan []byte
	Chats    map[string]bool
	mu       sync.RWMutex
}

func (c *Client) Subscribe(chatID string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.Chats == nil {
		c.Chats = make(map[string]bool)
	}
	c.Chats[chatID] = true
}

func (c *Client) Unsubscribe(chatID string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	delete(c.Chats, chatID)
}

func (c *Client) IsSubscribed(chatID string) bool {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.Chats[chatID]
}

type Hub struct {
	Clients    map[string]*Client
	Register   chan *Client
	Unregister chan *Client
	mu         sync.RWMutex
}

func NewHub() *Hub {
	return &Hub{
		Clients:    make(map[string]*Client),
		Register:   make(chan *Client),
		Unregister: make(chan *Client),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.Register:
			h.mu.Lock()
			h.Clients[client.UserID] = client
			h.mu.Unlock()

		case client := <-h.Unregister:
			h.mu.Lock()
			if existing, ok := h.Clients[client.UserID]; ok && existing == client {
				delete(h.Clients, client.UserID)
				close(client.Send)
			}
			h.mu.Unlock()
		}
	}
}

func (h *Hub) BroadcastToAll(message []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	for _, client := range h.Clients {
		select {
		case client.Send <- message:
		default:
		}
	}
}

func (h *Hub) BroadcastToChat(chatID string, message []byte, excludeUserID string) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	for userID, client := range h.Clients {
		if userID == excludeUserID {
			continue
		}
		if client.IsSubscribed(chatID) {
			select {
			case client.Send <- message:
			default:
			}
		}
	}
}

func (h *Hub) GetClient(userID string) *Client {
	h.mu.RLock()
	defer h.mu.RUnlock()
	return h.Clients[userID]
}

func (h *Hub) IsUserOnline(userID string) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()

	client, exists := h.Clients[userID]
	if !exists {
		return false
	}

	if client.Conn == nil {
		return false
	}

	return true
}
