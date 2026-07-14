package handlers

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"time"

	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

var AllowedEmojis = map[string]bool{
	"👍": true, "👎": true,
	"❤️": true, "🔥": true,
	"😂": true, "😮": true,
	"😢": true, "😡": true,
	"🎉": true, "🤔": true,
	"💯": true, "👀": true,
}

type ReactionResponse struct {
	Emoji      string         `json:"emoji"`
	Count      int            `json:"count"`
	Users      []ReactionUser `json:"users"`
	MyReaction bool           `json:"my_reaction"`
}

type ReactionUser struct {
	UserID   string `json:"user_id"`
	Username string `json:"username"`
}

func AddReaction(c *gin.Context) {
	messageIDStr := c.Param("message_id")
	messageID, err := uuid.Parse(messageIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный message_id"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	var req struct {
		Emoji string `json:"emoji" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат"})
		return
	}

	if !AllowedEmojis[req.Emoji] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Недопустимый эмодзи"})
		return
	}

	var message models.Message
	if err := database.DB.Where("id = ?", messageID).First(&message).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Сообщение не найдено"})
		return
	}

	var member models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", message.ChatID, userID).
		First(&member).Error; err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Вы не участник этого чата"})
		return
	}

	database.DB.Where("message_id = ? AND user_id = ?", messageID, userID).
		Delete(&models.MessageReaction{})

	reaction := models.MessageReaction{
		MessageID: messageID,
		UserID:    userID,
		Emoji:     req.Emoji,
	}
	if err := database.DB.Create(&reaction).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка добавления"})
		return
	}

	slog.Info("Реакция добавлена",
		"user_id", userID,
		"message_id", messageID,
		"emoji", req.Emoji,
	)

	if GlobalHub != nil {
		payload, _ := json.Marshal(map[string]interface{}{
			"message_id": messageID.String(),
			"chat_id":    message.ChatID.String(),
			"user_id":    userID.String(),
			"emoji":      req.Emoji,
			"action":     "added",
		})
		msg, _ := json.Marshal(map[string]interface{}{
			"type":      "message_reaction",
			"payload":   payload,
			"timestamp": time.Now().Format(time.RFC3339),
		})
		GlobalHub.BroadcastToChat(message.ChatID.String(), msg, "")
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Реакция добавлена",
		"reaction": gin.H{
			"emoji":      req.Emoji,
			"message_id": messageID.String(),
			"user_id":    userID.String(),
		},
	})
}

func RemoveReaction(c *gin.Context) {
	messageIDStr := c.Param("message_id")
	emoji := c.Param("emoji")

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

	result := database.DB.Where("message_id = ? AND user_id = ? AND emoji = ?",
		messageID, userID, emoji).Delete(&models.MessageReaction{})

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Реакция не найдена"})
		return
	}

	if GlobalHub != nil {
		payload, _ := json.Marshal(map[string]interface{}{
			"message_id": messageID.String(),
			"chat_id":    message.ChatID.String(),
			"user_id":    userID.String(),
			"emoji":      emoji,
			"action":     "removed",
		})
		msg, _ := json.Marshal(map[string]interface{}{
			"type":      "message_reaction",
			"payload":   payload,
			"timestamp": time.Now().Format(time.RFC3339),
		})
		GlobalHub.BroadcastToChat(message.ChatID.String(), msg, "")
	}

	c.JSON(http.StatusOK, gin.H{"message": "Реакция удалена"})
}

func GetReactions(c *gin.Context) {
	messageIDStr := c.Param("message_id")
	messageID, err := uuid.Parse(messageIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный message_id"})
		return
	}

	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	type ReactionGroup struct {
		Emoji string
		Count int64
	}
	var groups []ReactionGroup
	database.DB.Model(&models.MessageReaction{}).
		Select("emoji, COUNT(*) as count").
		Where("message_id = ?", messageID).
		Group("emoji").
		Scan(&groups)

	var myReactions []models.MessageReaction
	database.DB.Where("message_id = ? AND user_id = ?", messageID, userID).
		Find(&myReactions)
	myReactionsMap := make(map[string]bool)
	for _, r := range myReactions {
		myReactionsMap[r.Emoji] = true
	}

	result := []ReactionResponse{}
	for _, g := range groups {
		var users []ReactionUser
		var reactions []models.MessageReaction
		database.DB.Where("message_id = ? AND emoji = ?", messageID, g.Emoji).
			Find(&reactions)

		for _, r := range reactions {
			var user models.User
			if err := database.DB.Where("id = ?", r.UserID).First(&user).Error; err == nil {
				users = append(users, ReactionUser{
					UserID:   user.ID.String(),
					Username: user.Username,
				})
			}
		}

		result = append(result, ReactionResponse{
			Emoji:      g.Emoji,
			Count:      int(g.Count),
			Users:      users,
			MyReaction: myReactionsMap[g.Emoji],
		})
	}

	if result == nil {
		result = []ReactionResponse{}
	}

	c.JSON(http.StatusOK, gin.H{"reactions": result})
}
