package handlers

import (
	"net/http"
	"time"

	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type ForwardRequest struct {
	ChatID string `json:"chat_id" binding:"required"`
}

func ForwardMessage(c *gin.Context) {
	msgIDStr := c.Param("message_id")
	msgID, err := uuid.Parse(msgIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный message_id"})
		return
	}

	var req ForwardRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	targetChatID, err := uuid.Parse(req.ChatID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	var originalMsg models.Message
	if err := database.DB.Where("id = ?", msgID).First(&originalMsg).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Сообщение не найдено"})
		return
	}

	var member models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", targetChatID, userID).First(&member).Error; err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Вы не участник этого чата"})
		return
	}

	var originalSender models.User
	database.DB.Where("id = ?", originalMsg.SenderID).First(&originalSender)

	originalText := ""
	if originalMsg.Text != nil {
		originalText = *originalMsg.Text
	}
	forwardedText := " Переслано от " + originalSender.Username + ":\n" + originalText

	newMsg := models.Message{
		ID:        uuid.New(),
		ChatID:    targetChatID,
		SenderID:  userID,
		Type:      originalMsg.Type,
		Text:      &forwardedText,
		MediaURL:  originalMsg.MediaURL,
		Status:    "sent",
		CreatedAt: time.Now(),
	}

	if err := database.DB.Create(&newMsg).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка пересылки"})
		return
	}

	if GlobalHub != nil {
		BroadcastNewMessage(
			GlobalHub,
			newMsg.ID.String(),
			targetChatID.String(),
			userID.String(),
			"",
			forwardedText,
			newMsg.Type,
			newMsg.CreatedAt.Format(time.RFC3339),
		)
	}

	c.JSON(http.StatusOK, gin.H{
		"message":        "Сообщение переслано",
		"new_message_id": newMsg.ID.String(),
	})
}
