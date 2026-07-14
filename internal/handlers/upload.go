package handlers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"supernova/internal/config"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func UploadFile(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Файл не предоставлен"})
		return
	}

	if file.Size > 100*1024*1024 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "макс файл 100 мб (пока что)"})
		return
	}

	ext := filepath.Ext(file.Filename)
	newFilename := fmt.Sprintf("%s%s", uuid.New().String(), ext)

	uploadDir := config.Cfg.UploadDir
	if _, err := os.Stat(uploadDir); os.IsNotExist(err) {
		os.MkdirAll(uploadDir, 0755)
	}

	filePath := filepath.Join(uploadDir, newFilename)

	if err := c.SaveUploadedFile(file, filePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Ошибка сохранения файла"})
		return
	}

	fileURL := fmt.Sprintf("http://localhost:8080/uploads/%s", newFilename)

	c.JSON(http.StatusOK, gin.H{
		"file_url":  fileURL,
		"file_name": file.Filename,
		"file_size": file.Size,
	})
}
