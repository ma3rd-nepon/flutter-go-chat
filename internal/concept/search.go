package handlers

import (
	"net/http"
	"strings"

	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func GlobalSearch(c *gin.Context) {
	query := strings.TrimSpace(c.Query("q"))
	chatID := c.Query("chat_id")

	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Пустой запрос"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	if strings.HasPrefix(query, ">") {
		c.JSON(http.StatusOK, gin.H{
			"type":   "command",
			"action": "open_settings",
			"query":  query[1:],
		})
		return
	}

	lowerQuery := strings.ToLower(query)

	if strings.HasPrefix(lowerQuery, "user:") {
		handleUserSearch(c, query[5:], userID)
		return
	}

	if strings.HasPrefix(lowerQuery, "chat:") {
		handleChatSearch(c, query[5:], userID)
		return
	}

	if strings.HasPrefix(lowerQuery, "msg:") && chatID != "" {
		handleMessageSearch(c, query[4:], chatID)
		return
	}

	handleDefaultSearch(c, query, userID)
}

func handleUserSearch(c *gin.Context, term string, currentUserID uuid.UUID) {
	var users []models.User
	database.DB.Where("username ILIKE ? OR display_name ILIKE ?", "%"+term+"%", "%"+term+"%").
		Where("id != ?", currentUserID).
		Limit(20).
		Find(&users)

	c.JSON(http.StatusOK, gin.H{"type": "users", "results": users})
}

func handleChatSearch(c *gin.Context, term string, currentUserID uuid.UUID) {
	var chats []models.Chat
	database.DB.Table("chats").
		Joins("JOIN chat_members ON chat_members.chat_id = chats.id").
		Where("chat_members.user_id = ?", currentUserID).
		Where("chats.name ILIKE ?", "%"+term+"%").
		Limit(20).
		Find(&chats)

	c.JSON(http.StatusOK, gin.H{"type": "chats", "results": chats})
}

func handleMessageSearch(c *gin.Context, term string, chatID string) {
	var messages []models.Message
	database.DB.Where("chat_id = ? AND text ILIKE ?", chatID, "%"+term+"%").
		Order("created_at DESC").
		Limit(50).
		Find(&messages)

	c.JSON(http.StatusOK, gin.H{"type": "messages", "results": messages})
}

func handleDefaultSearch(c *gin.Context, term string, currentUserID uuid.UUID) {
	var users []models.User
	var chats []models.Chat

	database.DB.Where("username ILIKE ? OR display_name ILIKE ?", "%"+term+"%", "%"+term+"%").
		Where("id != ?", currentUserID).
		Limit(10).
		Find(&users)

	database.DB.Table("chats").
		Joins("JOIN chat_members ON chat_members.chat_id = chats.id").
		Where("chat_members.user_id = ?", currentUserID).
		Where("chats.name ILIKE ?", "%"+term+"%").
		Limit(10).
		Find(&chats)

	c.JSON(http.StatusOK, gin.H{
		"type":  "mixed",
		"users": users,
		"chats": chats,
	})
}
