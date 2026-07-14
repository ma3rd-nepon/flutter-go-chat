package handlers

import (
	"net/http"

	"supernova/internal/database"
	"supernova/internal/models"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type ChatMemberResponse struct {
	UserID      string  `json:"user_id"`
	Username    string  `json:"username"`
	DisplayName *string `json:"display_name"`
	AvatarURL   *string `json:"avatar_url"`
	Bio         *string `json:"bio"`
	Role        string  `json:"role"`
	IsOnline    bool    `json:"is_online"`
}

func GetChatMembers(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	var members []models.ChatMember
	if err := database.DB.Where("chat_id = ?", chatID).Find(&members).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	var responses []ChatMemberResponse
	for _, member := range members {
		var user models.User
		if err := database.DB.Where("id = ?", member.UserID).First(&user).Error; err == nil {
			isOnline := false
			if GlobalHub != nil {
				isOnline = GlobalHub.IsUserOnline(user.ID.String())
			}

			responses = append(responses, ChatMemberResponse{
				UserID:      user.ID.String(),
				Username:    user.Username,
				DisplayName: user.DisplayName,
				AvatarURL:   user.AvatarURL,
				Bio:         user.Bio,
				Role:        member.Role,
				IsOnline:    isOnline,
			})
		}
	}

	if responses == nil {
		responses = []ChatMemberResponse{}
	}

	c.JSON(http.StatusOK, gin.H{"members": responses})
}

func AddMember(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	var req struct {
		UserID string `json:"user_id" binding:"required"`
		Role   string `json:"role"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный формат данных"})
		return
	}

	userID, err := uuid.Parse(req.UserID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный user_id"})
		return
	}

	role := req.Role
	if role == "" {
		role = "member"
	}

	member := models.ChatMember{
		ChatID: chatID,
		UserID: userID,
		Role:   role,
	}

	if err := database.DB.Create(&member).Error; err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Пользователь уже в чате"})
		return
	}

	var addedUser models.User
	database.DB.Where("id = ?", userID).First(&addedUser)

	adderIDStr, _ := c.Get("user_id")
	var adder models.User
	database.DB.Where("id = ?", adderIDStr).First(&adder)

	systemText := adder.Username + " добавил(а) " + addedUser.Username
	CreateSystemMessage(chatID, systemText)

	c.JSON(http.StatusOK, gin.H{"message": "Участник добавлен"})
}

func RemoveMember(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	userIDStr := c.Param("user_id")

	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный user_id"})
		return
	}

	currentUserIDStr, _ := c.Get("user_id")
	currentUserID, _ := uuid.Parse(currentUserIDStr.(string))

	var removerMember models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", chatID, currentUserID).
		First(&removerMember).Error; err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Вы не участник этого чата"})
		return
	}

	if removerMember.Role != "owner" && removerMember.Role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Только администраторы могут удалять участников"})
		return
	}

	var removedUser models.User
	database.DB.Where("id = ?", userID).First(&removedUser)
	var removerUser models.User
	database.DB.Where("id = ?", currentUserID).First(&removerUser)

	if err := database.DB.Where("chat_id = ? AND user_id = ?", chatID, userID).
		Delete(&models.ChatMember{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка удаления"})
		return
	}

	systemText := removerUser.Username + " удалил(а) " + removedUser.Username
	CreateSystemMessage(chatID, systemText)

	c.JSON(http.StatusOK, gin.H{"message": "Участник удалён из чата"})
}

func LeaveChat(c *gin.Context) {
	chatIDStr := c.Param("chat_id")
	userIDStr, _ := c.Get("user_id")

	chatID, err := uuid.Parse(chatIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный chat_id"})
		return
	}

	userID, _ := uuid.Parse(userIDStr.(string))

	var member models.ChatMember
	if err := database.DB.Where("chat_id = ? AND user_id = ?", chatID, userID).
		First(&member).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Вы не участник этого чата"})
		return
	}

	if member.Role == "owner" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Создатель не может выйти из чата"})
		return
	}

	var leavingUser models.User
	database.DB.Where("id = ?", userID).First(&leavingUser)

	database.DB.Where("chat_id = ? AND user_id = ?", chatID, userID).
		Delete(&models.ChatMember{})

	systemText := leavingUser.Username + " вышел(ла) из чата"
	CreateSystemMessage(chatID, systemText)

	c.JSON(http.StatusOK, gin.H{"message": "Вы вышли из чата"})
}
