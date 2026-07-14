package handlers

import (
	"net/http"

	"supernova/internal/database"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Block struct {
	BlockerID uuid.UUID `gorm:"primaryKey;column:blocker_id"`
	BlockedID uuid.UUID `gorm:"primaryKey;column:blocked_id"`
}

func (Block) TableName() string {
	return "blocks"
}

func BlockUser(c *gin.Context) {
	blockedIDStr := c.Param("user_id")
	blockedID, err := uuid.Parse(blockedIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный user_id"})
		return
	}

	blockerIDStr, _ := c.Get("user_id")
	blockerID, _ := uuid.Parse(blockerIDStr.(string))

	if blockerID == blockedID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Нельзя заблокировать себя"})
		return
	}

	block := Block{BlockerID: blockerID, BlockedID: blockedID}

	database.DB.Create(&block)

	c.JSON(http.StatusOK, gin.H{"message": "Пользователь заблокирован"})
}

func UnblockUser(c *gin.Context) {
	blockedIDStr := c.Param("user_id")
	blockedID, err := uuid.Parse(blockedIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Неверный user_id"})
		return
	}

	blockerIDStr, _ := c.Get("user_id")
	blockerID, _ := uuid.Parse(blockerIDStr.(string))

	database.DB.Where("blocker_id = ? AND blocked_id = ?", blockerID, blockedID).Delete(&Block{})

	c.JSON(http.StatusOK, gin.H{"message": "Пользователь разблокирован"})
}

func IsBlocked(blockerID, blockedID uuid.UUID) bool {
	var count int64
	database.DB.Model(&Block{}).
		Where("(blocker_id = ? AND blocked_id = ?) OR (blocker_id = ? AND blocked_id = ?)",
			blockerID, blockedID, blockedID, blockerID).
		Count(&count)
	return count > 0
}
