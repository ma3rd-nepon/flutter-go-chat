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

type MuteRequest struct {
	Duration int `json:"duration"`
}

func MuteChat(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	var req MuteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	var mutedUntil *time.Time
	if req.Duration == -1 {
		forever := time.Date(2099, 1, 1, 0, 0, 0, 0, time.UTC)
		mutedUntil = &forever
	} else if req.Duration == 0 {
		mutedUntil = nil
	} else {
		until := time.Now().Add(time.Duration(req.Duration) * time.Second)
		mutedUntil = &until
	}

	result := database.DB.Model(&models.ChatMember{}).
		Where("chat_id = ? AND user_id = ?", chatID, userID).
		Update("muted_until", mutedUntil)

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Вы не участник этого чата"})
		return
	}

	status := "включен"
	if mutedUntil == nil {
		status = "выключен"
	}

	c.JSON(http.StatusOK, gin.H{
		"message":     "Уведомления " + status,
		"muted_until": mutedUntil,
	})
}

type TransferRequest struct {
	UserID string `json:"user_id" binding:"required"`
}

func TransferOwnership(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	var req TransferRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	newOwnerID, err := uuid.Parse(req.UserID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный user_id"})
		return
	}

	currentUserIDStr, _ := c.Get("user_id")
	currentUserID, _ := uuid.Parse(currentUserIDStr.(string))

	var currentMember models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", chatID, currentUserID).
		First(&currentMember).Error; err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Вы не участник этого чата"})
		return
	}
	if currentMember.Role != "owner" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Только владелец может передавать права"})
		return
	}

	var newMember models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", chatID, newOwnerID).
		First(&newMember).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Пользователь не является участником чата"})
		return
	}
	if newOwnerID == currentUserID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Нельзя передать права самому себе"})
		return
	}

	tx := database.DB.Begin()
	if err := tx.Model(&models.ChatMember{}).
		Where("chat_id = ? AND user_id = ?", chatID, currentUserID).
		Update("role", "member").Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка обновления"})
		return
	}

	if err := tx.Model(&models.ChatMember{}).
		Where("chat_id = ? AND user_id = ?", chatID, newOwnerID).
		Update("role", "owner").Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка обновления"})
		return
	}
	tx.Commit()

	var currentUser, newUser models.User
	database.DB.Where("id = ?", currentUserID).First(&currentUser)
	database.DB.Where("id = ?", newOwnerID).First(&newUser)

	systemText := currentUser.Username + " передал(а) права владельца " + newUser.Username
	CreateSystemMessage(chatID, systemText)

	if GlobalHub != nil {
		payload, _ := json.Marshal(map[string]interface{}{
			"chat_id":   chatID.String(),
			"new_owner": newUser.Username,
			"old_owner": currentUser.Username,
		})
		broadcastMsg, _ := json.Marshal(WebSocketMessage{
			Type:      "chat_transferred",
			Payload:   payload,
			Timestamp: time.Now().Format(time.RFC3339),
		})
		GlobalHub.BroadcastToChat(chatID.String(), broadcastMsg, "")
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "Права владельца переданы",
		"new_owner": newUser.Username,
	})
}
