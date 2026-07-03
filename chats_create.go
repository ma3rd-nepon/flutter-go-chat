package handlers

import (
	"net/http"
	"time"

	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type CreateChatRequest struct {
	Name    string   `json:"name"`
	Type    string   `json:"type" binding:"required,oneof=private group channel"`
	UserIDs []string `json:"user_ids" binding:"required,min=1"`
}

func CreateChat(c *gin.Context) {
	var req CreateChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	creatorIDStr, _ := c.Get("user_id")
	creatorID, _ := uuid.Parse(creatorIDStr.(string))

	chat := models.Chat{
		ID:        uuid.New(),
		Name:      &req.Name,
		ChatType:  req.Type,
		CreatedAt: time.Now(),
	}

	if err := database.DB.Create(&chat).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка создания чата"})
		return
	}

	creatorMember := models.ChatMember{
		ChatID:   chat.ID,
		UserID:   creatorID,
		Role:     "owner",
		JoinedAt: time.Now(),
	}
	database.DB.Create(&creatorMember)

	for _, userIDStr := range req.UserIDs {
		userID, err := uuid.Parse(userIDStr)
		if err != nil {
			continue
		}
		if userID == creatorID {
			continue
		}

		member := models.ChatMember{
			ChatID:   chat.ID,
			UserID:   userID,
			Role:     "member",
			JoinedAt: time.Now(),
		}
		database.DB.Create(&member)
	}

	c.JSON(http.StatusCreated, gin.H{"chat": chat})
}
