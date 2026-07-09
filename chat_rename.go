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

type RenameChatRequest struct {
	Name string `json:"name" binding:"required"`
}

func RenameChat(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	var req RenameChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
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
		c.JSON(http.StatusForbidden, gin.H{"error": "Только администраторы могут переименовывать чат"})
		return
	}

	var chat models.Chat
	database.DB.Where("id = ?", chatID).First(&chat)
	oldName := ""
	if chat.Name != nil {
		oldName = *chat.Name
	}

	if err := database.DB.Model(&models.Chat{}).
		Where("id = ?", chatID).
		Update("name", req.Name).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка обновления"})
		return
	}

	var user models.User
	database.DB.Where("id = ?", userID).First(&user)

	systemText := user.Username + " переименовал(а) чат из \"" + oldName + "\" в \"" + req.Name + "\""
	CreateSystemMessage(chatID, systemText)

	if GlobalHub != nil {
		payload, _ := json.Marshal(map[string]interface{}{
			"chat_id":    chatID.String(),
			"new_name":   req.Name,
			"renamed_by": user.Username,
		})

		broadcastMsg, _ := json.Marshal(WebSocketMessage{
			Type:      "chat_renamed",
			Payload:   payload,
			Timestamp: time.Now().Format(time.RFC3339),
		})

		GlobalHub.BroadcastToChat(chatID.String(), broadcastMsg, "")
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Чат переименован",
		"name":    req.Name,
	})
}
