package api

import (
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/httprate"

	"supernova/internal/api/handlers"
	authmw "supernova/internal/api/middleware"
	"supernova/internal/api/response"
	appjwt "supernova/internal/pkg/jwt"
)

type Handlers struct {
	Auth          *handlers.AuthHandler
	Users         *handlers.UserHandler
	Blocks        *handlers.BlockHandler
	Friends       *handlers.FriendHandler
	Chats         *handlers.ChatHandler
	Messages      *handlers.MessageHandler
	Reactions     *handlers.ReactionHandler
	Uploads       *handlers.UploadHandler
	Notifications *handlers.NotificationHandler
	Voice         *handlers.VoiceHandler
	Sessions      *handlers.SessionHandler
	Mute          *handlers.MuteHandler
	Roles         *handlers.RoleHandler
	Restrictions  *handlers.RestrictionHandler
	Bans          *handlers.BanHandler
	WS            *handlers.WSHandler
}

func NewRouter(h *Handlers, jwtService *appjwt.Service, uploadDir string) http.Handler {
	r := chi.NewRouter()

	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)

	r.Use(httprate.LimitByIP(120, time.Minute))

	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		response.OK(w, r, map[string]any{
			"status": "ok",
			"time":   time.Now().UTC().Unix(),
		})
	})

	if uploadDir != "" {
		r.Handle("/uploads/*", http.StripPrefix("/uploads/", staticUploads(uploadDir)))
	}

	r.Get("/ws", h.WS.Handle)

	r.Route("/auth", func(r chi.Router) {
		r.Post("/register", h.Auth.Register)
		r.Post("/login", h.Auth.Login)
		r.Post("/refresh", h.Auth.Refresh)

		r.Group(func(r chi.Router) {
			r.Use(authmw.Auth(jwtService))
			r.Post("/logout", h.Auth.Logout)

			r.Get("/sessions", h.Sessions.List)
			r.Post("/sessions/revoke", h.Sessions.Revoke)
		})
	})

	r.Group(func(r chi.Router) {
		r.Use(authmw.Auth(jwtService))

		r.Get("/users/me", h.Users.Me)
		r.Patch("/users/me", h.Users.UpdateMe)
		r.Get("/users", h.Users.Search)
		r.Get("/users/{userID}", h.Users.Get)

		r.Post("/uploads/avatar", h.Uploads.UploadAvatar)
		r.Post("/uploads/banner", h.Uploads.UploadBanner)

		r.Post("/block", h.Blocks.Block)
		r.Post("/unblock", h.Blocks.Unblock)
		r.Get("/blocks", h.Blocks.List)

		r.Post("/friends/request", h.Friends.Request)
		r.Post("/friends/accept", h.Friends.Accept)
		r.Post("/friends/reject", h.Friends.Reject)
		r.Post("/friends/remove", h.Friends.Remove)
		r.Get("/friends", h.Friends.List)
		r.Get("/friends/requests", h.Friends.Requests)

		r.Post("/chats", h.Chats.Create)
		r.Get("/chats", h.Chats.List)
		r.Get("/chats/search", h.Chats.Search)
		r.Get("/chats/{chatID}", h.Chats.Get)
		r.Patch("/chats/{chatID}", h.Chats.Update)
		r.Delete("/chats/{chatID}", h.Chats.Delete)

		r.Get("/chats/{chatID}/members", h.Chats.ListMembers)
		r.Get("/chats/{chatID}/companion", h.Chats.Companion)
		r.Post("/chats/{chatID}/members", h.Bans.AddMember)
		r.Delete("/chats/{chatID}/members/{userID}", h.Chats.RemoveMember)

		r.Post("/chats/{chatID}/members/{userID}/admin", h.Roles.SetAdmin)
		r.Delete("/chats/{chatID}/members/{userID}/admin", h.Roles.RemoveAdmin)
		r.Post("/chats/{chatID}/owner/{userID}", h.Roles.TransferOwner)
		r.Post("/chats/{chatID}/members/{userID}/kick", h.Roles.Kick)

		r.Post("/chats/{chatID}/members/{userID}/restrict", h.Restrictions.Restrict)
		r.Delete("/chats/{chatID}/members/{userID}/restrict", h.Restrictions.Unrestrict)

		r.Post("/chats/{chatID}/bans", h.Bans.Ban)
		r.Delete("/chats/{chatID}/bans/{userID}", h.Bans.Unban)
		r.Get("/chats/{chatID}/bans", h.Bans.List)

		r.Post("/chats/{chatID}/mute", h.Mute.Mute)
		r.Delete("/chats/{chatID}/mute", h.Mute.Unmute)
		r.Get("/chats/{chatID}/mute", h.Mute.Status)

		r.Post("/chats/{chatID}/avatar", h.Uploads.UploadChatAvatar)
		r.Post("/chats/{chatID}/attachments", h.Uploads.UploadAttachment)

		r.Post("/chats/{chatID}/pin", h.Chats.Pin)
		r.Post("/chats/{chatID}/unpin", h.Chats.Unpin)

		r.Patch("/chats/{chatID}/settings", h.Chats.UpdateSettings)

		r.Get("/chats/{chatID}/read-status", h.Chats.ReadStatus)

		r.Get("/chats/{chatID}/messages", h.Messages.List)
		r.Get("/chats/{chatID}/messages/search", h.Messages.Search)
		r.Post("/chats/{chatID}/messages", h.Messages.Create)
		r.Post("/chats/{chatID}/read", h.Messages.MarkRead)

		r.Get("/chats/{chatID}/pinned", h.Messages.GetPinned)
		r.Post("/chats/{chatID}/messages/{messageID}/pin", h.Messages.Pin)
		r.Delete("/chats/{chatID}/messages/{messageID}/pin", h.Messages.Unpin)

		r.Patch("/messages/{messageID}", h.Messages.Update)
		r.Delete("/messages/{messageID}", h.Messages.Delete)
		r.Post("/messages/{messageID}/forward", h.Messages.Forward)
		r.Get("/messages/{messageID}/read-by", h.Messages.ReadBy)

		r.Get("/messages/{messageID}/reactions", h.Reactions.List)
		r.Post("/messages/{messageID}/reactions", h.Reactions.Add)
		r.Delete("/messages/{messageID}/reactions/{emoji}", h.Reactions.Remove)

		r.Get("/notifications", h.Notifications.List)
		r.Post("/notifications/read", h.Notifications.Read)
		r.Post("/notifications/read-all", h.Notifications.ReadAll)

		r.Post("/voice/channels", h.Voice.Create)
		r.Get("/voice/channels/{channelID}", h.Voice.Get)
		r.Post("/voice/channels/{channelID}/join", h.Voice.Join)
		r.Post("/voice/channels/{channelID}/leave", h.Voice.Leave)
	})

	r.NotFound(func(w http.ResponseWriter, r *http.Request) {
		response.NotFound(w, r, "route not found")
	})

	r.MethodNotAllowed(func(w http.ResponseWriter, r *http.Request) {
		response.MethodNotAllowed(w, r, "method not allowed")
	})

	return r
}

func staticUploads(dir string) http.Handler {
	fs := http.FileServer(http.Dir(dir))

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		cleaned := filepath.Clean("/" + r.URL.Path)

		if strings.Contains(cleaned, "..") {
			http.NotFound(w, r)
			return
		}

		fullPath := filepath.Join(dir, cleaned)

		info, err := os.Stat(fullPath)
		if err != nil || info.IsDir() {
			http.NotFound(w, r)
			return
		}

		w.Header().Set("Cache-Control", "public, max-age=3600")

		fs.ServeHTTP(w, r)
	})
}
