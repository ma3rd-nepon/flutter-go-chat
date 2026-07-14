package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func PinMessage(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	messageIDStr := c.Param("message_id")

	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	messageID, err := uuid.Parse(messageIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный message_id"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	var member models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", chatID, userID).
		First(&member).Error; err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Вы не участник этого чата"})
		return
	}

	if member.Role != "owner" && member.Role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Только администраторы могут закреплять сообщения"})
		return
	}

	var message models.Message
	if err := database.DB.Where("id = ? AND chat_id = ?", messageID, chatID).
		First(&message).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Сообщение не найдено"})
		return
	}

	if err := database.DB.Model(&models.Chat{}).
		Where("id = ?", chatID).
		Update("pinned_message_id", messageID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка закрепления"})
		return
	}

	var user models.User
	database.DB.Where("id = ?", userID).First(&user)

	systemText := user.Username + " закрепил(а) сообщение"
	CreateSystemMessage(chatID, systemText)

	if GlobalHub != nil {
		var sender models.User
		database.DB.Where("id = ?", message.SenderID).First(&sender)

		text := ""
		if message.Text != nil {
			text = *message.Text
		}

		payload, _ := json.Marshal(map[string]interface{}{
			"chat_id":    chatID.String(),
			"message_id": messageID.String(),
			"pinned_by":  user.Username,
			"message": map[string]interface{}{
				"id":        message.ID.String(),
				"text":      text,
				"sender_id": message.SenderID.String(),
				"username":  sender.Username,
				"type":      message.Type,
			},
		})

		broadcastMsg, _ := json.Marshal(WebSocketMessage{
			Type:      "message_pinned",
			Payload:   payload,
			Timestamp: time.Now().Format(time.RFC3339),
		})

		GlobalHub.BroadcastToChat(chatID.String(), broadcastMsg, "")
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "Сообщение закреплено",
		"pinned_id": messageID.String(),
	})
}

func UnpinMessage(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	var member models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", chatID, userID).
		First(&member).Error; err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Вы не участник этого чата"})
		return
	}

	if member.Role != "owner" && member.Role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Только администраторы могут откреплять сообщения"})
		return
	}

	if err := database.DB.Model(&models.Chat{}).
		Where("id = ?", chatID).
		Update("pinned_message_id", nil).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка открепления"})
		return
	}

	var user models.User
	database.DB.Where("id = ?", userID).First(&user)

	systemText := user.Username + " открепил(а) сообщение"
	CreateSystemMessage(chatID, systemText)

	if GlobalHub != nil {
		payload, _ := json.Marshal(map[string]interface{}{
			"chat_id": chatID.String(),
		})

		broadcastMsg, _ := json.Marshal(WebSocketMessage{
			Type:      "message_unpinned",
			Payload:   payload,
			Timestamp: time.Now().Format(time.RFC3339),
		})

		GlobalHub.BroadcastToChat(chatID.String(), broadcastMsg, "")
	}

	c.JSON(http.StatusOK, gin.H{"message": "Сообщение откреплено"})
}

func GetPinnedMessage(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	var chat models.Chat
	if err := database.DB.Where("id = ?", chatID).First(&chat).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Чат не найден"})
		return
	}

	if chat.PinnedMessageID == nil {
		c.JSON(http.StatusOK, gin.H{"pinned_message": nil})
		return
	}

	var message models.Message
	if err := database.DB.Where("id = ?", *chat.PinnedMessageID).First(&message).Error; err != nil {
		c.JSON(http.StatusOK, gin.H{"pinned_message": nil})
		return
	}

	var sender models.User
	database.DB.Where("id = ?", message.SenderID).First(&sender)

	text := ""
	if message.Text != nil {
		text = *message.Text
	}

	c.JSON(http.StatusOK, gin.H{
		"pinned_message": gin.H{
			"id":         message.ID.String(),
			"text":       text,
			"sender_id":  message.SenderID.String(),
			"username":   sender.Username,
			"type":       message.Type,
			"media_url":  message.MediaURL,
			"created_at": message.CreatedAt,
		},
	})
}
