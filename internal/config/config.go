package config

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	ServerAddr string

	DatabaseURL string

	JWTSecret       string
	AccessTokenTTL  time.Duration
	RefreshTokenTTL time.Duration

	UploadDir         string
	MaxAvatarSize     int64
	MaxBannerSize     int64
	MaxAttachmentSize int64

	CORSAllowedOrigins []string
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	serverAddr := getEnv("SERVER_ADDR", ":8080")

	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		return nil, fmt.Errorf("JWT_SECRET is required")
	}

	if len(jwtSecret) < 32 {
		return nil, fmt.Errorf("JWT_SECRET must be at least 32 characters")
	}

	accessTokenTTL, err := getDuration("ACCESS_TOKEN_TTL", 15*time.Minute)
	if err != nil {
		return nil, err
	}

	refreshTokenTTL, err := getDuration("REFRESH_TOKEN_TTL", 720*time.Hour)
	if err != nil {
		return nil, err
	}

	if accessTokenTTL <= 0 {
		return nil, fmt.Errorf("ACCESS_TOKEN_TTL must be greater than 0")
	}

	if refreshTokenTTL <= accessTokenTTL {
		return nil, fmt.Errorf("REFRESH_TOKEN_TTL must be greater than ACCESS_TOKEN_TTL")
	}

	uploadDir := getEnv("UPLOAD_DIR", "./uploads")

	maxAvatarSize, err := getInt64("MAX_AVATAR_SIZE", 10*1024*1024)
	if err != nil {
		return nil, err
	}

	maxBannerSize, err := getInt64("MAX_BANNER_SIZE", 10*1024*1024)
	if err != nil {
		return nil, err
	}

	maxAttachmentSize, err := getInt64("MAX_ATTACHMENT_SIZE", 50*1024*1024)
	if err != nil {
		return nil, err
	}

	if maxAvatarSize <= 0 {
		return nil, fmt.Errorf("MAX_AVATAR_SIZE must be greater than 0")
	}

	if maxBannerSize <= 0 {
		return nil, fmt.Errorf("MAX_BANNER_SIZE must be greater than 0")
	}

	if maxAttachmentSize <= 0 {
		return nil, fmt.Errorf("MAX_ATTACHMENT_SIZE must be greater than 0")
	}

	corsAllowedOrigins := getCORSAllowedOrigins()
	if len(corsAllowedOrigins) == 0 {
		corsAllowedOrigins = []string{
			"http://localhost:5173",
		}
	}

	return &Config{
		ServerAddr:         serverAddr,
		DatabaseURL:        databaseURL,
		JWTSecret:          jwtSecret,
		AccessTokenTTL:     accessTokenTTL,
		RefreshTokenTTL:    refreshTokenTTL,
		UploadDir:          uploadDir,
		MaxAvatarSize:      maxAvatarSize,
		MaxBannerSize:      maxBannerSize,
		MaxAttachmentSize:  maxAttachmentSize,
		CORSAllowedOrigins: corsAllowedOrigins,
	}, nil
}

func (c *Config) EnsureUploadDirs() error {
	dirs := []string{
		filepath.Join(c.UploadDir, "avatars"),
		filepath.Join(c.UploadDir, "banners"),
		filepath.Join(c.UploadDir, "chats"),
		filepath.Join(c.UploadDir, "attachments"),
	}

	for _, dir := range dirs {
		if err := os.MkdirAll(dir, 0o755); err != nil {
			return fmt.Errorf("create upload dir %s: %w", dir, err)
		}
	}

	return nil
}

func getEnv(key string, defaultValue string) string {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}

	return value
}

func getDuration(key string, defaultValue time.Duration) (time.Duration, error) {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue, nil
	}

	duration, err := time.ParseDuration(value)
	if err != nil {
		return 0, fmt.Errorf("%s: invalid duration: %w", key, err)
	}

	return duration, nil
}

func getInt64(key string, defaultValue int64) (int64, error) {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue, nil
	}

	parsed, err := strconv.ParseInt(value, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("%s: invalid int64: %w", key, err)
	}

	return parsed, nil
}

func getCORSAllowedOrigins() []string {
	raw := os.Getenv("CORS_ALLOWED_ORIGINS")
	if raw == "" {
		return []string{}
	}

	parts := strings.Split(raw, ",")
	result := make([]string, 0, len(parts))

	for _, part := range parts {
		trimmed := strings.TrimSpace(part)
		if trimmed != "" {
			result = append(result, trimmed)
		}
	}

	return result
}
