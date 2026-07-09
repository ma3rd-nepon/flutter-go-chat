package handlers

import (
	"log/slog"
	"net/http"
	"time"

	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func UpdateLastSeen(c *gin.Context) {
	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	now := time.Now()

	err := database.DB.Model(&models.User{}).
		Where("id = ?", userID).
		Update("last_seen", now).Error

	if err != nil {
		slog.Error("Ошибка обновления last_seen", "error", err, "user_id", userID)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка обновления статуса"})
		return
	}

	if GlobalHub != nil {
		GlobalHub.BroadcastOnlineStatus(userID.String(), true)
	}

	c.JSON(http.StatusOK, gin.H{"status": "ok", "last_seen": now})
}

func GetUserStatus(c *gin.Context) {
	targetUserID := c.Param("user_id")

	var user models.User
	if err := database.DB.Where("id = ?", targetUserID).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Пользователь не найден"})
		return
	}

	isOnline := false
	if GlobalHub != nil {
		isOnline = GlobalHub.IsUserOnline(targetUserID)
	}

	c.JSON(http.StatusOK, gin.H{
		"user_id":   user.ID.String(),
		"username":  user.Username,
		"is_online": isOnline,
		"last_seen": user.LastSeen,
	})
}

func GetUsersStatus(c *gin.Context) {
	var req struct {
		UserIDs []string `json:"user_ids"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	var users []models.User
	database.DB.Where("id IN ?", req.UserIDs).Find(&users)

	result := make([]map[string]interface{}, 0, len(users))
	for _, user := range users {
		isOnline := false
		if GlobalHub != nil {
			isOnline = GlobalHub.IsUserOnline(user.ID.String())
		}

		result = append(result, map[string]interface{}{
			"user_id":   user.ID.String(),
			"username":  user.Username,
			"is_online": isOnline,
			"last_seen": user.LastSeen,
		})
	}

	c.JSON(http.StatusOK, gin.H{"users": result})
}
