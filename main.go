package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	"supernova/internal/config"
	"supernova/internal/database"
	"supernova/internal/handlers"
	"supernova/internal/hub"
	"supernova/internal/middleware"

	"github.com/gin-gonic/gin"
)

func main() {
	cfg := config.Load()

	logHandler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: config.GetLogLevel(),
	})
	logger := slog.New(logHandler)
	slog.SetDefault(logger)

	slog.Info("Запуск Supernova",
		"port", cfg.AppPort,
		"log_level", cfg.LogLevel,
	)

	database.Connect()

	hubInstance := hub.NewHub()
	go hubInstance.Run()

	handlers.GlobalHub = hubInstance

	r := gin.Default()

	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	r.POST("/api/register", handlers.Register)
	r.POST("/api/login", handlers.Login)

	r.GET("/uploads/*filepath", func(c *gin.Context) {
		filepath := c.Param("filepath")
		c.File("./uploads" + filepath)
	})

	r.GET("/test", func(c *gin.Context) {
		c.File("./test_api.html")
	})

	api := r.Group("/api")
	api.Use(middleware.AuthMiddleware())
	{
		api.GET("/users/me", handlers.GetCurrentUser)
		api.PUT("/users/me", handlers.UpdateProfile)
		api.GET("/users/search", handlers.SearchUsers)
		api.GET("/users/:user_id", handlers.GetUserByID)
		api.POST("/users/me/status", handlers.UpdateLastSeen)
		api.GET("/users/:user_id/status", handlers.GetUserStatus)
		api.POST("/users/status/bulk", handlers.GetUsersStatus)
		api.GET("/chats", handlers.GetChats)
		api.POST("/chats", handlers.CreateChat)
		api.POST("/chats/private", handlers.CreatePrivateChat)
		api.GET("/chats/:chat_id/messages", handlers.GetMessages)
		api.GET("/chats/:chat_id/sync", handlers.SyncMessages)
		api.GET("/chats/:chat_id/messages/search", handlers.SearchMessages)
		api.GET("/chats/:chat_id/members", handlers.GetChatMembers)
		api.POST("/chats/:chat_id/members", handlers.AddMember)
		api.POST("/chats/:chat_id/add_by_username", handlers.AddMemberByUsername)
		api.DELETE("/chats/:chat_id/members/:user_id", handlers.RemoveMember)
		api.POST("/chats/:chat_id/leave", handlers.LeaveChat)
		api.POST("/chats/:chat_id/read", handlers.MarkMessagesAsRead)
		api.POST("/chats/:chat_id/typing", handlers.SendTyping)
		api.POST("/chats/:chat_id/mute", handlers.MuteChat)
		api.POST("/chats/:chat_id/transfer", handlers.TransferOwnership)
		api.PUT("/chats/:chat_id", handlers.RenameChat)
		api.POST("/chats/:chat_id/pin/:message_id", handlers.PinMessage)
		api.DELETE("/chats/:chat_id/pin", handlers.UnpinMessage)
		api.GET("/chats/:chat_id/pinned", handlers.GetPinnedMessage)

		api.POST("/messages", handlers.SendMessage)
		api.PUT("/messages/:message_id", handlers.EditMessage)
		api.DELETE("/messages/:message_id", handlers.DeleteMessage)
		api.POST("/messages/:message_id/forward", handlers.ForwardMessage)

		api.POST("/users/:user_id/block", handlers.BlockUser)
		api.DELETE("/users/:user_id/block", handlers.UnblockUser)

		api.POST("/upload", handlers.UploadFile)

		api.GET("/ws", handlers.HandleWebSocket(hubInstance))

		api.GET("/ping", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"message": "подо мной supernova"})
		})
	}

	addr := fmt.Sprintf(":%s", cfg.AppPort)
	slog.Info("Сервер запущен", "addr", addr)
	slog.Info("HTML клиент", "url", fmt.Sprintf("http://localhost:%s/test", cfg.AppPort))
	slog.Info("WebSocket", "url", fmt.Sprintf("ws://localhost:%s/api/ws", cfg.AppPort))

	if err := r.Run(addr); err != nil {
		slog.Error("Ошибка запуска сервера", "error", err)
		os.Exit(1)
	}
}
