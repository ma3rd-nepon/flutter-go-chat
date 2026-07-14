package handlers

import (
	"net/http"
	"strconv"

	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func SearchMessages(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	queryStr := c.Query("query")
	if queryStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Требуется query"})
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	if limit > 50 {
		limit = 50
	}

	var messages []models.Message
	if err := database.DB.Where("chat_id = ? AND is_deleted = ? AND text ILIKE ?", chatID, false, "%"+queryStr+"%").
		Order("created_at DESC").
		Limit(limit).
		Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	userIDs := make(map[string]bool)
	for _, msg := range messages {
		userIDs[msg.SenderID.String()] = true
	}

	var users []models.User
	if len(userIDs) > 0 {
		ids := make([]string, 0, len(userIDs))
		for id := range userIDs {
			ids = append(ids, id)
		}
		database.DB.Where("id IN ?", ids).Find(&users)
	}

	userMap := make(map[string]models.User)
	for _, u := range users {
		userMap[u.ID.String()] = u
	}

	var result []MessageResponse
	for _, msg := range messages {
		sender, exists := userMap[msg.SenderID.String()]
		fromUser := UserBrief{}
		if exists {
			fromUser = UserBrief{
				ID:          sender.ID.String(),
				Username:    sender.Username,
				DisplayName: sender.DisplayName,
				AvatarURL:   sender.AvatarURL,
			}
		}

		content := []ContentBlock{}
		if msg.Text != nil && *msg.Text != "" {
			content = append(content, ContentBlock{Type: "text", Value: *msg.Text})
		}
		if msg.MediaURL != nil && *msg.MediaURL != "" {
			mediaType := msg.Type
			if mediaType == "" || mediaType == "text" {
				mediaType = "photo"
			}
			content = append(content, ContentBlock{Type: mediaType, URL: *msg.MediaURL})
		}
		if len(content) == 0 && msg.Type != "system" {
			content = append(content, ContentBlock{Type: "text", Value: ""})
		}
		if msg.Type == "system" {
			systemText := ""
			if msg.Text != nil {
				systemText = *msg.Text
			}
			content = []ContentBlock{{Type: "system", Value: systemText}}
		}

		result = append(result, MessageResponse{
			ID:        msg.ID,
			ChatID:    msg.ChatID,
			FromUser:  fromUser,
			Content:   content,
			Status:    msg.Status,
			IsDeleted: msg.IsDeleted,
			EditedAt:  msg.EditedAt,
			CreatedAt: msg.CreatedAt,
			UpdatedAt: msg.CreatedAt,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"messages": result,
		"count":    len(result),
	})
}
