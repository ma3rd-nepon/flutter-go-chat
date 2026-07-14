package database

import (
	"fmt"
	"log/slog"

	"supernova/internal/config"
	"supernova/internal/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func Connect() {
	cfg := config.Cfg

	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=UTC",
		cfg.DBHost, cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBPort,
	)

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		slog.Error("Не удалось подключиться к БД", "error", err)
		panic("failed to connect database")
	}

	slog.Info("Подключение к БД установлено",
		"host", cfg.DBHost,
		"db", cfg.DBName,
	)

	AutoMigrate()
}

func AutoMigrate() {
	DB.AutoMigrate(
		&models.User{},
		&models.Chat{},
		&models.ChatMember{},
		&models.Message{},
		&models.MessageStatus{},
		&models.MessageReaction{},
	)
}
