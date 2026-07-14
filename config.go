package config

import (
	"log/slog"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	AppPort        string
	DBHost         string
	DBPort         string
	DBUser         string
	DBPassword     string
	DBName         string
	JWTSecret      string
	JWTExpiryHours int
	UploadDir      string
	LogLevel       string
}

var Cfg *Config

func Load() *Config {
	godotenv.Load()

	expiry, _ := strconv.Atoi(getEnv("JWT_EXPIRY_HOURS", "720"))

	Cfg = &Config{
		AppPort:        getEnv("APP_PORT", "8080"),
		DBHost:         getEnv("DB_HOST", "localhost"),
		DBPort:         getEnv("DB_PORT", "5432"),
		DBUser:         getEnv("DB_USER", "postgres"),
		DBPassword:     getEnv("DB_PASSWORD", "MetSunSawedOfWire_C++2407"),
		DBName:         getEnv("DB_NAME", "messenger_db"),
		JWTSecret:      getEnv("JWT_SECRET", "default-secret"),
		JWTExpiryHours: expiry,
		UploadDir:      getEnv("UPLOAD_DIR", "./uploads"),
		LogLevel:       getEnv("LOG_LEVEL", "info"),
	}

	return Cfg
}

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func GetLogLevel() slog.Level {
	switch Cfg.LogLevel {
	case "debug":
		return slog.LevelDebug
	case "warn":
		return slog.LevelWarn
	case "error":
		return slog.LevelError
	default:
		return slog.LevelInfo
	}
}
