package handlers

import (
	"net/http"
	"strconv"

	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type ReplyInfo struct {
	ID       string `json:"id"`
	Username string `json:"username"`
	Text     string `json:"text"`
	Type     string `json:"type"`
}

type ChatWithUnread struct {
	models.Chat
	UnreadCount int `json:"unread_count"`
}

func GetChats(c *gin.Context) {
	userIDStr, _ := c.Get("user_id")
	userID, _ := uuid.Parse(userIDStr.(string))

	var chatMembers []models.ChatMember
	database.DB.Where("user_id = ?", userID).Find(&chatMembers)

	var chatsWithDetails []gin.H
	for _, member := range chatMembers {
		var chat models.Chat
		database.DB.Where("id = ?", member.ChatID).First(&chat)

		chatInfo := gin.H{
			"id":              chat.ID.String(),
			"chat_type":       chat.ChatType,
			"name":            chat.Name,
			"unread_count":    0,
			"last_message":    nil,
			"last_message_at": nil,
		}

		if chat.ChatType == "private" {
			var companionMember models.ChatMember
			database.DB.Where("chat_id = ? AND user_id != ?", chat.ID, userID).First(&companionMember)

			var companion models.User
			database.DB.Where("id = ?", companionMember.UserID).First(&companion)

			isOnline := false
			if GlobalHub != nil {
				isOnline = GlobalHub.IsUserOnline(companion.ID.String())
			}

			chatInfo["companion"] = gin.H{
				"id":           companion.ID.String(),
				"username":     companion.Username,
				"display_name": companion.DisplayName,
				"avatar_url":   companion.AvatarURL,
				"is_online":    isOnline,
				"last_seen":    companion.LastSeen,
			}
			chatInfo["name"] = companion.DisplayName
			if chatInfo["name"] == nil || chatInfo["name"] == "" {
				chatInfo["name"] = companion.Username
			}
		}

		chatsWithDetails = append(chatsWithDetails, chatInfo)
	}

	c.JSON(http.StatusOK, gin.H{"chats": chatsWithDetails})
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

		var replyTo *ReplyInfo
		if msg.ReplyToID != nil {
			var original models.Message
			if err := database.DB.Where("id = ?", *msg.ReplyToID).First(&original).Error; err == nil {
				origSender, origExists := userMap[original.SenderID.String()]
				if !origExists {
					database.DB.Where("id = ?", original.SenderID).First(&origSender)
				}
				origText := ""
				if original.Text != nil {
					origText = *original.Text
				}
				replyTo = &ReplyInfo{
					ID:       original.ID.String(),
					Username: origSender.Username,
					Text:     origText,
					Type:     original.Type,
				}
			}
		}

		result = append(result, MessageResponse{
			ID:        msg.ID,
			ChatID:    msg.ChatID,
			FromUser:  fromUser,
			Content:   content,
			ReplyTo:   replyTo,
			Status:    msg.Status,
			IsDeleted: msg.IsDeleted,
			EditedAt:  msg.EditedAt,
			CreatedAt: msg.CreatedAt,
			UpdatedAt: msg.CreatedAt,
		})
	}

	var total int64
	database.DB.Model(&models.Message{}).
		Where("chat_id = ? AND is_deleted = ?", chatID, false).
		Count(&total)

	c.JSON(http.StatusOK, gin.H{
		"messages": result,
		"pagination": gin.H{
			"page":     page,
			"limit":    limit,
			"total":    total,
			"has_more": int64(page*limit) < total,
		},
	})
}
