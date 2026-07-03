package handlers

import (
	"net/http"
	"strconv"
	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
)

func GetChats(c *gin.Context) {
	userIDStr := c.Query("user_id")
	if userIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Требуется user_id"})
		return
	}

	var members []models.ChatMember
	if err := database.DB.Where("user_id = ?", userIDStr).Find(&members).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	var chatIDs []string
	for _, member := range members {
		chatIDs = append(chatIDs, member.ChatID.String())
	}

	var chats []models.Chat
	if len(chatIDs) > 0 {
		if err := database.DB.Where("id IN ?", chatIDs).Find(&chats).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"chats": chats})
}

func GetMessages(c *gin.Context) {
	chatID := c.Param("chat_id")

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))

	if limit > 100 {
		limit = 100
	}
	if page < 1 {
		page = 1
	}

	offset := (page - 1) * limit

	var messages []models.Message
	if err := database.DB.Where("chat_id = ? AND is_deleted = ?", chatID, false).
		Order("created_at DESC").
		Limit(limit).
		Offset(offset).
		Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	for i, j := 0, len(messages)-1; i < j; i, j = i+1, j-1 {
		messages[i], messages[j] = messages[j], messages[i]
	}

	var total int64
	database.DB.Model(&models.Message{}).
		Where("chat_id = ? AND is_deleted = ?", chatID, false).
		Count(&total)

	c.JSON(http.StatusOK, gin.H{
		"messages": messages,
		"pagination": gin.H{
			"page":     page,
			"limit":    limit,
			"total":    total,
			"has_more": int64(page*limit) < total,
		},
	})
}
