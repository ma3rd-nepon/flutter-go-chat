package handlers

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"time"

	"supernova/internal/database"
	"supernova/internal/hub"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var wsUpgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

const (
	MsgTypeNewMessage     = "new_message"
	MsgTypeTyping         = "typing"
	MsgTypeStopTyping     = "stop_typing"
	MsgTypeReadReceipt    = "read_receipt"
	MsgTypeOnlineStatus   = "online_status"
	MsgTypeMessageEdited  = "message_edited"
	MsgTypeMessageDeleted = "message_deleted"
	MsgTypeSubscribe      = "subscribe"
	MsgTypeError          = "error"
)

type WebSocketMessage struct {
	Type      string          `json:"type"`
	Payload   json.RawMessage `json:"payload"`
	Timestamp string          `json:"timestamp"`
}

type MessagePayload struct {
	ID        string         `json:"id"`
	ChatID    string         `json:"chat_id"`
	FromUser  UserBrief      `json:"from_user"`
	Content   []ContentBlock `json:"content"`
	Status    string         `json:"status"`
	CreatedAt string         `json:"created_at"`
	UpdatedAt string         `json:"updated_at"`
}

type TypingPayload struct {
	ChatID   string `json:"chat_id"`
	UserID   string `json:"user_id"`
	Username string `json:"username"`
}

type ReadReceiptPayload struct {
	ChatID     string   `json:"chat_id"`
	MessageIDs []string `json:"message_ids"`
	UserID     string   `json:"user_id"`
	ReadAt     string   `json:"read_at"`
}

type OnlineStatusPayload struct {
	UserID   string `json:"user_id"`
	Username string `json:"username"`
	IsOnline bool   `json:"is_online"`
}

type MessageEditPayload struct {
	MessageID string `json:"message_id"`
	ChatID    string `json:"chat_id"`
	NewText   string `json:"new_text"`
	EditedAt  string `json:"edited_at"`
}

type MessageDeletePayload struct {
	MessageID string `json:"message_id"`
	ChatID    string `json:"chat_id"`
	DeletedAt string `json:"deleted_at"`
}

type SubscribePayload struct {
	ChatID string `json:"chat_id"`
}

func HandleWebSocket(hubInstance *hub.Hub) gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, exists := c.Get("user_id")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Требуется авторизация"})
			return
		}

		username := c.GetString("username")

		conn, err := wsUpgrader.Upgrade(c.Writer, c.Request, nil)
		if err != nil {
			slog.Error("Ошибка upgrade", "error", err)
			return
		}

		client := &hub.Client{
			Hub:      hubInstance,
			Conn:     conn,
			UserID:   userID.(string),
			Username: username,
			Send:     make(chan []byte, 256),
		}

		client.Hub.Register <- client

		broadcastOnlineStatus(hubInstance, userID.(string), username, true)

		go writePump(client)
		go readPump(client)
	}
}

func broadcastOnlineStatus(h *hub.Hub, userID, username string, isOnline bool) {
	payload, _ := json.Marshal(OnlineStatusPayload{
		UserID:   userID,
		Username: username,
		IsOnline: isOnline,
	})

	message, _ := json.Marshal(WebSocketMessage{
		Type:      MsgTypeOnlineStatus,
		Payload:   payload,
		Timestamp: time.Now().Format(time.RFC3339),
	})

	h.BroadcastToAll(message)
}

func BroadcastNewMessage(h *hub.Hub, messageID, chatID, senderID, username, text, messageType, createdAt string) {
	fromUser := UserBrief{
		ID:       senderID,
		Username: username,
	}

	if senderID != "" && senderID != "00000000-0000-0000-0000-000000000000" {
		var sender models.User
		if err := database.DB.Where("id = ?", senderID).First(&sender).Error; err == nil {
			fromUser = UserBrief{
				ID:          sender.ID.String(),
				Username:    sender.Username,
				DisplayName: sender.DisplayName,
				AvatarURL:   sender.AvatarURL,
			}
		}
	}

	content := []ContentBlock{}
	if text != "" {
		content = append(content, ContentBlock{Type: "text", Value: text})
	}
	if len(content) == 0 {
		content = append(content, ContentBlock{Type: messageType, Value: ""})
	}

	payload, _ := json.Marshal(MessagePayload{
		ID:        messageID,
		ChatID:    chatID,
		FromUser:  fromUser,
		Content:   content,
		Status:    "delivered",
		CreatedAt: createdAt,
		UpdatedAt: createdAt,
	})

	message, _ := json.Marshal(WebSocketMessage{
		Type:      MsgTypeNewMessage,
		Payload:   payload,
		Timestamp: time.Now().Format(time.RFC3339),
	})

	h.BroadcastToChat(chatID, message, senderID)
}

func BroadcastTyping(h *hub.Hub, chatID, userID, username string) {
	payload, _ := json.Marshal(TypingPayload{
		ChatID:   chatID,
		UserID:   userID,
		Username: username,
	})

	message, _ := json.Marshal(WebSocketMessage{
		Type:      MsgTypeTyping,
		Payload:   payload,
		Timestamp: time.Now().Format(time.RFC3339),
	})

	h.BroadcastToChat(chatID, message, userID)
}

func BroadcastReadReceipt(h *hub.Hub, chatID, userID string, messageIDs []string) {
	payload, _ := json.Marshal(ReadReceiptPayload{
		ChatID:     chatID,
		MessageIDs: messageIDs,
		UserID:     userID,
		ReadAt:     time.Now().Format(time.RFC3339),
	})

	message, _ := json.Marshal(WebSocketMessage{
		Type:      MsgTypeReadReceipt,
		Payload:   payload,
		Timestamp: time.Now().Format(time.RFC3339),
	})

	h.BroadcastToChat(chatID, message, userID)
}

func writePump(c *hub.Client) {
	defer func() {
		c.Conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.Send:
			if !ok {
				c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.Conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			if err := w.Close(); err != nil {
				return
			}
		}
	}
}

func readPump(c *hub.Client) {
	defer func() {
		c.Hub.Unregister <- c
		broadcastOnlineStatus(c.Hub, c.UserID, c.Username, false)
		c.Conn.Close()
	}()

	for {
		_, message, err := c.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				slog.Error("Ошибка чтения", "error", err)
			}
			break
		}

		var wsMsg WebSocketMessage
		if err := json.Unmarshal(message, &wsMsg); err != nil {
			slog.Error("Ошибка парсинга", "error", err)
			continue
		}

		switch wsMsg.Type {
		case MsgTypeSubscribe:
			var payload SubscribePayload
			if err := json.Unmarshal(wsMsg.Payload, &payload); err == nil {
				c.Subscribe(payload.ChatID)
				slog.Info("Клиент подписался на чат", "user_id", c.UserID, "chat_id", payload.ChatID)
			}

		case MsgTypeTyping:
			var payload TypingPayload
			if err := json.Unmarshal(wsMsg.Payload, &payload); err == nil {
				BroadcastTyping(c.Hub, payload.ChatID, c.UserID, c.Username)
			}

		case MsgTypeStopTyping:
			var payload struct {
				ChatID string `json:"chat_id"`
			}
			if err := json.Unmarshal(wsMsg.Payload, &payload); err == nil {
				stopTypingMsg, _ := json.Marshal(WebSocketMessage{
					Type:      MsgTypeStopTyping,
					Payload:   wsMsg.Payload,
					Timestamp: time.Now().Format(time.RFC3339),
				})
				c.Hub.BroadcastToChat(payload.ChatID, stopTypingMsg, c.UserID)
			}

		case MsgTypeReadReceipt:
			var payload ReadReceiptPayload
			if err := json.Unmarshal(wsMsg.Payload, &payload); err == nil {
				BroadcastReadReceipt(c.Hub, payload.ChatID, c.UserID, payload.MessageIDs)
			}

		default:
			slog.Warn("Неизвестный тип сообщения", "type", wsMsg.Type)
		}
	}
}
