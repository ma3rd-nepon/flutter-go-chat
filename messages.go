package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"supernova/internal/database"
	"supernova/internal/hub"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type SendMessageRequest struct {
	ChatID   string `json:"chat_id" binding:"required"`
	Text     string `json:"text"`
	Type     string `json:"type" binding:"omitempty,oneof=text photo video voice document sticker service"`
	MediaURL string `json:"media_url"`
	ReplyTo  string `json:"reply_to"`
}

var GlobalHub *hub.Hub

func SendMessage(c *gin.Context) {
	var req SendMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	username := c.GetString("username")

	userID, err := uuid.Parse(userIDStr.(string))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный user_id"})
		return
	}

	chatID, err := uuid.Parse(req.ChatID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	msgType := req.Type
	if msgType == "" {
		if req.MediaURL != "" {
			msgType = "photo"
		} else {
			msgType = "text"
		}
	}

	message := models.Message{
		ID:        uuid.New(),
		ChatID:    chatID,
		SenderID:  userID,
		Type:      msgType,
		Text:      &req.Text,
		MediaURL:  &req.MediaURL,
		Status:    "sent",
		IsDeleted: false,
		CreatedAt: time.Now(),
	}

	if req.ReplyTo != "" {
		replyToID, err := uuid.Parse(req.ReplyTo)
		if err == nil {
			message.ReplyToID = &replyToID
		}
	}

	if err := database.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка отправки сообщения"})
		return
	}

	if GlobalHub != nil {
		BroadcastNewMessage(
			GlobalHub,
			message.ID.String(),
			chatID.String(),
			userID.String(),
			username,
			req.Text,
			msgType,
			message.CreatedAt.Format(time.RFC3339),
		)
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": message,
	})
}

func EditMessage(c *gin.Context) {
	messageIDStr := c.Param("message_id")
	messageID, err := uuid.Parse(messageIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный message_id"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	var req struct {
		Text string `json:"text" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	var message models.Message
	if err := database.DB.Where("id = ?", messageID).First(&message).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Сообщение не найдено"})
		return
	}

	if message.SenderID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "Можно редактировать только свои сообщения"})
		return
	}

	editedAt := time.Now()
	message.Text = &req.Text
	message.EditedAt = &editedAt

	if err := database.DB.Save(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка редактирования"})
		return
	}

	if GlobalHub != nil {
		payload, _ := json.Marshal(MessageEditPayload{
			MessageID: messageID.String(),
			ChatID:    message.ChatID.String(),
			NewText:   req.Text,
			EditedAt:  editedAt.Format(time.RFC3339),
		})

		broadcastMsg, _ := json.Marshal(WebSocketMessage{
			Type:      MsgTypeMessageEdited,
			Payload:   payload,
			Timestamp: time.Now().Format(time.RFC3339),
		})

		GlobalHub.BroadcastToChat(message.ChatID.String(), broadcastMsg, userID.String())
	}

	c.JSON(http.StatusOK, gin.H{"message": "Сообщение отредактировано"})
}

func DeleteMessage(c *gin.Context) {
	messageIDStr := c.Param("message_id")
	messageID, err := uuid.Parse(messageIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный message_id"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	var message models.Message
	if err := database.DB.Where("id = ?", messageID).First(&message).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Сообщение не найдено"})
		return
	}

	var member models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", message.ChatID, userID).
		First(&member).Error; err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Нет прав"})
		return
	}

	if message.SenderID != userID && member.Role != "admin" && member.Role != "owner" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Нет прав на удаление"})
		return
	}

	deletedAt := time.Now()
	message.IsDeleted = true
	message.Text = &[]string{"[Удалено]"}[0]
	message.EditedAt = &deletedAt

	if err := database.DB.Save(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка удаления"})
		return
	}

	if GlobalHub != nil {
		payload, _ := json.Marshal(MessageDeletePayload{
			MessageID: messageID.String(),
			ChatID:    message.ChatID.String(),
			DeletedAt: deletedAt.Format(time.RFC3339),
		})

		broadcastMsg, _ := json.Marshal(WebSocketMessage{
			Type:      MsgTypeMessageDeleted,
			Payload:   payload,
			Timestamp: time.Now().Format(time.RFC3339),
		})

		GlobalHub.BroadcastToChat(message.ChatID.String(), broadcastMsg, userID.String())
	}

	c.JSON(http.StatusOK, gin.H{"message": "Сообщение удалено"})
}

func MarkMessagesAsRead(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	var lastMessage models.Message
	if err := database.DB.Where("chat_id = ?", chatID).
		Order("created_at DESC").
		First(&lastMessage).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Сообщения не найдены"})
		return
	}

	database.DB.Model(&models.ChatMember{}).
		Where("chat_id = ? AND user_id = ?", chatID, userID).
		Update("last_read_message_id", lastMessage.ID)

	if GlobalHub != nil {
		payload, _ := json.Marshal(map[string]interface{}{
			"chat_id": chatID.String(),
			"user_id": userID.String(),
		})

		broadcastMsg, _ := json.Marshal(WebSocketMessage{
			Type:      "messages_read",
			Payload:   payload,
			Timestamp: time.Now().Format(time.RFC3339),
		})

		GlobalHub.BroadcastToChat(chatID.String(), broadcastMsg, userID.String())
	}

	c.JSON(http.StatusOK, gin.H{
		"message":           "Статус обновлен",
		"last_read_message": lastMessage.ID,
	})
}

func SendTyping(c *gin.Context) {
	chatID := c.Param("chat_id")
	userID, _ := c.Get("user_id")
	username := c.GetString("username")

	if GlobalHub != nil {
		BroadcastTyping(GlobalHub, chatID, userID.(string), username)
	}

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}
