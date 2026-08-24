package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"supernova/internal/api"
	"supernova/internal/api/handlers"
	"supernova/internal/config"
	"supernova/internal/db"
	"supernova/internal/pkg/hasher"
	appjwt "supernova/internal/pkg/jwt"
	"supernova/internal/pkg/storage"
	"supernova/internal/pkg/validator"
	"supernova/internal/repository"
	"supernova/internal/service"
	"supernova/internal/ws"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	cfg, err := config.Load()
	if err != nil {
		slog.Error("failed to load config", "error", err)
		os.Exit(1)
	}

	if err := cfg.EnsureUploadDirs(); err != nil {
		slog.Error("failed to create upload dirs", "error", err)
		os.Exit(1)
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	pool, err := db.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		slog.Error("failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer pool.Close()

	slog.Info("database connected")

	// Repositories
	userRepo := repository.NewUserRepository(pool)
	refreshTokenRepo := repository.NewRefreshTokenRepository(pool)
	blockRepo := repository.NewBlockRepository(pool)
	friendRepo := repository.NewFriendRepository(pool)
	chatRepo := repository.NewChatRepository(pool)
	messageRepo := repository.NewMessageRepository(pool)
	reactionRepo := repository.NewReactionRepository(pool)
	notificationRepo := repository.NewNotificationRepository(pool)
	voiceRepo := repository.NewVoiceRepository(pool)
	banRepo := repository.NewChatBanRepository(pool)
	attachmentRepo := repository.NewAttachmentRepository(pool)

	// Pkg
	passwordHasher := hasher.NewPasswordHasher()
	jwtService := appjwt.NewService(cfg.JWTSecret, cfg.AccessTokenTTL)
	v := validator.New()
	localStorage := storage.NewLocalStorage(cfg.UploadDir)

	// WebSocket hub
	hub := ws.NewHub()

	// Services
	authService := service.NewAuthService(
		userRepo,
		refreshTokenRepo,
		passwordHasher,
		jwtService,
		cfg.RefreshTokenTTL,
	)

	blockService := service.NewBlockService(
		blockRepo,
		userRepo,
	)

	friendService := service.NewFriendService(
		friendRepo,
		userRepo,
	)

	chatService := service.NewChatService(
		chatRepo,
		userRepo,
	)

	messageService := service.NewMessageService(
		messageRepo,
		chatRepo,
		attachmentRepo,
	)

	reactionService := service.NewReactionService(
		reactionRepo,
		messageRepo,
		chatRepo,
	)

	eventService := service.NewEventService(
		hub,
		chatRepo,
	)

	notificationService := service.NewNotificationService(
		notificationRepo,
		hub,
	)

	presenceService := service.NewPresenceService(
		userRepo,
		friendRepo,
		hub,
	)

	voiceService := service.NewVoiceService(
		voiceRepo,
		chatRepo,
	)

	sessionService := service.NewSessionService(
		refreshTokenRepo,
	)

	uploadService := service.NewUploadService(
		localStorage,
		userRepo,
		chatRepo,
		attachmentRepo,
		service.UploadConfig{
			MaxAvatarSize:     cfg.MaxAvatarSize,
			MaxBannerSize:     cfg.MaxBannerSize,
			MaxAttachmentSize: cfg.MaxAttachmentSize,
		},
	)

	muteService := service.NewMuteService(
		chatRepo,
	)

	roleService := service.NewRoleService(
		chatRepo,
	)

	restrictionService := service.NewRestrictionService(
		chatRepo,
	)

	banService := service.NewBanService(
		banRepo,
		chatRepo,
	)

	messageNotificationService := service.NewMessageNotificationService(
		notificationRepo,
		chatRepo,
		userRepo,
		hub,
	)

	// Presence hooks
	hub.OnConnect = presenceService.SetOnline
	hub.OnDisconnect = presenceService.SetOffline

	// Handlers
	authHandler := handlers.NewAuthHandler(authService, v)
	userHandler := handlers.NewUserHandler(userRepo, v)
	blockHandler := handlers.NewBlockHandler(blockService)
	friendHandler := handlers.NewFriendHandler(friendService, notificationService)
	chatHandler := handlers.NewChatHandler(chatService, eventService)
	messageHandler := handlers.NewMessageHandler(messageService, eventService, messageNotificationService, userRepo, reactionService, attachmentRepo)
	reactionHandler := handlers.NewReactionHandler(reactionService, eventService)
	uploadHandler := handlers.NewUploadHandler(uploadService, eventService)
	notificationHandler := handlers.NewNotificationHandler(notificationService)
	voiceHandler := handlers.NewVoiceHandler(voiceService, eventService)
	sessionHandler := handlers.NewSessionHandler(sessionService)
	muteHandler := handlers.NewMuteHandler(muteService)
	roleHandler := handlers.NewRoleHandler(roleService)
	restrictionHandler := handlers.NewRestrictionHandler(restrictionService, eventService)
	banHandler := handlers.NewBanHandler(banService)
	wsHandler := handlers.NewWSHandler(hub, jwtService, eventService)

	h := &api.Handlers{
		Auth:          authHandler,
		Users:         userHandler,
		Blocks:        blockHandler,
		Friends:       friendHandler,
		Chats:         chatHandler,
		Messages:      messageHandler,
		Reactions:     reactionHandler,
		Uploads:       uploadHandler,
		Notifications: notificationHandler,
		Voice:         voiceHandler,
		Sessions:      sessionHandler,
		Mute:          muteHandler,
		Roles:         roleHandler,
		Restrictions:  restrictionHandler,
		Bans:          banHandler,
		WS:            wsHandler,
	}

	router := api.NewRouter(h, jwtService, cfg.UploadDir)

	srv := &http.Server{
		Addr:              cfg.ServerAddr,
		Handler:           router,
		ReadHeaderTimeout: 10 * time.Second,
		IdleTimeout:       120 * time.Second,
		MaxHeaderBytes:    1 << 20,
	}

	go func() {
		slog.Info("server started", "addr", cfg.ServerAddr)

		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			slog.Error("server failed", "error", err)
			os.Exit(1)
		}
	}()

	<-ctx.Done()

	slog.Info("shutdown signal received")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		slog.Error("server shutdown failed", "error", err)
		return
	}

	slog.Info("server stopped")
}
