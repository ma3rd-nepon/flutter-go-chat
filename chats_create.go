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
	UserIDs []string `json:"user_ids"`
}

type CreatePrivateChatRequest struct {
	Username string `json:"username" binding:"required"`
}

type AddByUsernameRequest struct {
	Username string `json:"username" binding:"required"`
	Role     string `json:"role"`
}

func CreateSystemMessage(chatID uuid.UUID, text string) *models.Message {
	systemText := text
	msg := &models.Message{
		ID:        uuid.New(),
		ChatID:    chatID,
		SenderID:  uuid.Nil,
		Type:      "system",
		Text:      &systemText,
		Status:    "delivered",
		IsDeleted: false,
		CreatedAt: time.Now(),
	}

	if err := database.DB.Create(msg).Error; err != nil {
		return nil
	}

	if GlobalHub != nil {
		BroadcastNewMessage(
			GlobalHub,
			msg.ID.String(),
			chatID.String(),
			"",
			"system",
			text,
			"system",
			msg.CreatedAt.Format(time.RFC3339),
		)
	}

	return msg
}

func CreatePrivateChat(c *gin.Context) {
	var req CreatePrivateChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	creatorIDStr, _ := c.Get("user_id")
	creatorID, _ := uuid.Parse(creatorIDStr.(string))

	var companion models.User
	if err := database.DB.Where("username = ?", req.Username).First(&companion).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Пользователь не найден"})
		return
	}

	if companion.ID == creatorID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Нельзя создать чат с самим собой"})
		return
	}

	var existingChat models.Chat
	err := database.DB.Joins("JOIN chat_members cm1 ON cm1.chat_id = chats.id").
		Joins("JOIN chat_members cm2 ON cm2.chat_id = chats.id").
		Where("chats.chat_type = ? AND cm1.user_id = ? AND cm2.user_id = ?", "private", creatorID, companion.ID).
		First(&existingChat).Error

	if err == nil {
		c.JSON(http.StatusOK, gin.H{
			"chat":    existingChat,
			"message": "Чат уже существует",
		})
		return
	}

	chat := models.Chat{
		ID:        uuid.New(),
		ChatType:  "private",
		CreatedAt: time.Now(),
	}

	if err := database.DB.Create(&chat).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка создания чата"})
		return
	}

	member1 := models.ChatMember{
		ChatID:   chat.ID,
		UserID:   creatorID,
		Role:     "member",
		JoinedAt: time.Now(),
	}
	member2 := models.ChatMember{
		ChatID:   chat.ID,
		UserID:   companion.ID,
		Role:     "member",
		JoinedAt: time.Now(),
	}
	database.DB.Create(&member1)
	database.DB.Create(&member2)

	CreateSystemMessage(chat.ID, "Личный чат создан")

	c.JSON(http.StatusCreated, gin.H{
		"chat":      chat,
		"companion": companion,
	})
}

func CreateChat(c *gin.Context) {
	var req CreateChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	creatorIDStr, _ := c.Get("user_id")
	creatorID, _ := uuid.Parse(creatorIDStr.(string))

	var creator models.User
	database.DB.Where("id = ?", creatorID).First(&creator)

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

	if req.UserIDs != nil {
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
	}

	// Системное сообщение
	var systemText string
	if req.Name != "" {
		systemText = creator.Username + " создал(а) группу \"" + req.Name + "\""
	} else {
		systemText = creator.Username + " создал(а) группу"
	}
	CreateSystemMessage(chat.ID, systemText)

	c.JSON(http.StatusCreated, gin.H{"chat": chat})
}

func AddMemberByUsername(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	var req AddByUsernameRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	var user models.User
	if err := database.DB.Where("username = ?", req.Username).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Пользователь не найден"})
		return
	}

	currentUserIDStr, _ := c.Get("user_id")
	currentUserID, _ := uuid.Parse(currentUserIDStr.(string))

	var adminMember models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", chatID, currentUserID).
		First(&adminMember).Error; err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Вы не участник этого чата"})
		return
	}

	if adminMember.Role != "owner" && adminMember.Role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Только администраторы могут добавлять участников"})
		return
	}

	var existingMember models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", chatID, user.ID).
		First(&existingMember).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Пользователь уже в чате"})
		return
	}

	role := req.Role
	if role == "" {
		role = "member"
	}

	member := models.ChatMember{
		ChatID: chatID,
		UserID: user.ID,
		Role:   role,
	}

	if err := database.DB.Create(&member).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка добавления"})
		return
	}

	var adminUser models.User
	database.DB.Where("id = ?", currentUserID).First(&adminUser)

	systemText := adminUser.Username + " добавил(а) " + user.Username
	CreateSystemMessage(chatID, systemText)

	c.JSON(http.StatusOK, gin.H{
		"message": "Участник добавлен",
		"user":    user,
	})
}
