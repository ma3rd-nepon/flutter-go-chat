package main

import (
	"log"
	"net/http"

	"supernova/internal/database"
	"supernova/internal/handlers"
	"supernova/internal/hub"
	"supernova/internal/middleware"

	"github.com/gin-gonic/gin"
)

func main() {
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

	r.Static("/uploads", "./uploads")
	r.StaticFile("/test", "./test_api.html")

	api := r.Group("/api")
	api.Use(middleware.AuthMiddleware())
	{
		api.GET("/users/me", handlers.GetCurrentUser)
		api.PUT("/users/me", handlers.UpdateProfile)
		api.GET("/users/search", handlers.SearchUsers)
		api.GET("/users/:user_id", handlers.GetUserByID)
		api.GET("/chats", handlers.GetChats)
		api.POST("/chats", handlers.CreateChat)
		api.GET("/chats/:chat_id/messages", handlers.GetMessages)
		api.GET("/chats/:chat_id/members", handlers.GetChatMembers)
		api.POST("/chats/:chat_id/members", handlers.AddMember)
		api.DELETE("/chats/:chat_id/members/:user_id", handlers.RemoveMember)
		api.POST("/chats/:chat_id/leave", handlers.LeaveChat)
		api.POST("/messages", handlers.SendMessage)
		api.PUT("/messages/:message_id", handlers.EditMessage)
		api.DELETE("/messages/:message_id", handlers.DeleteMessage)
		api.POST("/chats/:chat_id/read", handlers.MarkAsRead)
		api.POST("/chats/:chat_id/typing", handlers.SendTyping)
		api.POST("/upload", handlers.UploadFile)
		api.GET("/ws", handlers.HandleWebSocket(hubInstance))
		api.GET("/ping", func(c *gin.Context) {
			c.JSON(http.StatusOK, gin.H{"message": "подо мной supernova"})
		})
	}

	log.Println("Запуск сервера на http://localhost:8080")
	r.Run(":8080")
}
