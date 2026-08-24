package service

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/hasher"
	appjwt "supernova/internal/pkg/jwt"
	"supernova/internal/repository"
)

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrTokenExpired       = errors.New("token expired")
	ErrTokenRevoked       = errors.New("token revoked")
	ErrTokenInvalid       = errors.New("token invalid")
)

type AuthService struct {
	users         *repository.UserRepository
	refreshTokens *repository.RefreshTokenRepository
	hasher        *hasher.PasswordHasher
	jwt           *appjwt.Service
	refreshTTL    time.Duration
}

func NewAuthService(
	users *repository.UserRepository,
	refreshTokens *repository.RefreshTokenRepository,
	hasher *hasher.PasswordHasher,
	jwtService *appjwt.Service,
	refreshTTL time.Duration,
) *AuthService {
	return &AuthService{
		users:         users,
		refreshTokens: refreshTokens,
		hasher:        hasher,
		jwt:           jwtService,
		refreshTTL:    refreshTTL,
	}
}

type AuthResult struct {
	User         *domain.User
	AccessToken  string
	RefreshToken string
	ExpiresAt    time.Time
}

func (s *AuthService) Register(ctx context.Context, email, password, displayName string, username *string) (*AuthResult, error) {
	hashedPassword, err := s.hasher.Hash(password)
	if err != nil {
		return nil, fmt.Errorf("hash password: %w", err)
	}

	now := time.Now().UTC()

	user := &domain.User{
		ID:           uuid.New(),
		Email:        email,
		PasswordHash: hashedPassword,
		Username:     username,
		DisplayName:  displayName,
		Status:       domain.UserStatusOffline,
		CreatedAt:    now,
		UpdatedAt:    now,
	}

	if err := s.users.Create(ctx, user); err != nil {
		return nil, err
	}

	return s.issueTokens(ctx, user, "", "")
}

func (s *AuthService) Login(ctx context.Context, email, password, userAgent, ip string) (*AuthResult, error) {
	user, err := s.users.GetByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			return nil, ErrInvalidCredentials
		}
		return nil, err
	}

	if err := s.hasher.Verify(password, user.PasswordHash); err != nil {
		return nil, ErrInvalidCredentials
	}

	return s.issueTokens(ctx, user, userAgent, ip)
}

func (s *AuthService) Refresh(ctx context.Context, refreshToken, userAgent, ip string) (*AuthResult, error) {
	tokenHash := hasher.HashOpaqueToken(refreshToken)

	stored, err := s.refreshTokens.GetByHash(ctx, tokenHash)
	if err != nil {
		return nil, ErrTokenInvalid
	}

	if stored.RevokedAt != nil {
		return nil, ErrTokenRevoked
	}

	if time.Now().UTC().After(stored.ExpiresAt) {
		return nil, ErrTokenExpired
	}

	// Ротация: старый токен отзываем
	if err := s.refreshTokens.Revoke(ctx, tokenHash); err != nil {
		return nil, err
	}

	user, err := s.users.GetByID(ctx, stored.UserID.String())
	if err != nil {
		return nil, err
	}

	return s.issueTokens(ctx, user, userAgent, ip)
}

func (s *AuthService) Logout(ctx context.Context, refreshToken string) error {
	tokenHash := hasher.HashOpaqueToken(refreshToken)
	return s.refreshTokens.Revoke(ctx, tokenHash)
}

func (s *AuthService) issueTokens(ctx context.Context, user *domain.User, userAgent, ip string) (*AuthResult, error) {
	accessToken, expiresAt, err := s.jwt.GenerateAccessToken(user.ID)
	if err != nil {
		return nil, fmt.Errorf("generate access token: %w", err)
	}

	refreshToken, err := appjwt.GenerateRefreshToken()
	if err != nil {
		return nil, fmt.Errorf("generate refresh token: %w", err)
	}

	tokenHash := hasher.HashOpaqueToken(refreshToken)

	now := time.Now().UTC()

	rt := &domain.RefreshToken{
		ID:        uuid.New(),
		UserID:    user.ID,
		TokenHash: tokenHash,
		ExpiresAt: now.Add(s.refreshTTL),
		CreatedAt: now,
	}

	if userAgent != "" {
		rt.UserAgent = &userAgent
	}
	if ip != "" {
		rt.IP = &ip
	}

	if err := s.refreshTokens.Create(ctx, rt); err != nil {
		return nil, err
	}

	return &AuthResult{
		User:         user,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresAt:    expiresAt,
	}, nil
}
