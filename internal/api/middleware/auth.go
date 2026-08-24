package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/google/uuid"

	"supernova/internal/api/response"
	appjwt "supernova/internal/pkg/jwt"
)

type ctxKey string

const UserIDKey ctxKey = "user_id"

func Auth(jwtService *appjwt.Service) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			header := r.Header.Get("Authorization")
			if header == "" {
				response.Unauthorized(w, r, "Authorization header is required")
				return
			}

			parts := strings.SplitN(header, " ", 2)
			if len(parts) != 2 || parts[0] != "Bearer" {
				response.Unauthorized(w, r, "Invalid authorization header format")
				return
			}

			claims, err := jwtService.ParseAccessToken(parts[1])
			if err != nil {
				response.Unauthorized(w, r, "Invalid or expired token")
				return
			}

			ctx := context.WithValue(r.Context(), UserIDKey, claims.UserID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func UserIDFromContext(ctx context.Context) (uuid.UUID, bool) {
	v, ok := ctx.Value(UserIDKey).(uuid.UUID)
	return v, ok
}
