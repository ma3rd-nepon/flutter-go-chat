package jwt

import (
	"crypto/rand"
	"encoding/base64"
	"errors"
	"fmt"
	"time"

	jwtlib "github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

var (
	ErrInvalidToken     = errors.New("invalid token")
	ErrInvalidTokenType = errors.New("invalid token type")
)

type Claims struct {
	UserID    uuid.UUID `json:"uid"`
	TokenType string    `json:"type"`

	jwtlib.RegisteredClaims
}

type Service struct {
	secret    []byte
	accessTTL time.Duration
	issuer    string
}

func NewService(secret string, accessTTL time.Duration) *Service {
	return &Service{
		secret:    []byte(secret),
		accessTTL: accessTTL,
		issuer:    "supernova",
	}
}

func (s *Service) GenerateAccessToken(userID uuid.UUID) (string, time.Time, error) {
	now := time.Now().UTC()
	expiresAt := now.Add(s.accessTTL)

	claims := Claims{
		UserID:    userID,
		TokenType: "access",
		RegisteredClaims: jwtlib.RegisteredClaims{
			Issuer:    s.issuer,
			Subject:   userID.String(),
			IssuedAt:  jwtlib.NewNumericDate(now),
			ExpiresAt: jwtlib.NewNumericDate(expiresAt),
		},
	}

	token := jwtlib.NewWithClaims(jwtlib.SigningMethodHS256, claims)

	signed, err := token.SignedString(s.secret)
	if err != nil {
		return "", time.Time{}, fmt.Errorf("sign access token: %w", err)
	}

	return signed, expiresAt, nil
}

func (s *Service) ParseAccessToken(rawToken string) (*Claims, error) {
	token, err := jwtlib.ParseWithClaims(
		rawToken,
		&Claims{},
		func(t *jwtlib.Token) (interface{}, error) {
			if _, ok := t.Method.(*jwtlib.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
			}

			return s.secret, nil
		},
		jwtlib.WithValidMethods([]string{"HS256"}),
		jwtlib.WithIssuer(s.issuer),
		jwtlib.WithExpirationRequired(),
	)
	if err != nil {
		return nil, err
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrInvalidToken
	}

	if claims.TokenType != "access" {
		return nil, ErrInvalidTokenType
	}

	if claims.UserID == uuid.Nil {
		return nil, ErrInvalidToken
	}

	return claims, nil
}

func GenerateRefreshToken() (string, error) {
	b := make([]byte, 32)

	if _, err := rand.Read(b); err != nil {
		return "", fmt.Errorf("generate refresh token: %w", err)
	}

	return base64.RawURLEncoding.EncodeToString(b), nil
}
