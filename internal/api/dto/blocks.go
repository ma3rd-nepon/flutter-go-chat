package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type BlockRequest struct {
	UserID uuid.UUID `json:"user_id"`
}

type UnblockRequest struct {
	UserID uuid.UUID `json:"user_id"`
}

type BlockResponse struct {
	BlockedUserID uuid.UUID         `json:"blocked_user_id"`
	CreatedAt     unixtime.UnixTime `json:"created_at"`
}

type UnblockResponse struct {
	UnblockedUserID uuid.UUID `json:"unblocked_user_id"`
}

type BlockedUserResponse struct {
	BlockedUserID uuid.UUID         `json:"blocked_user_id"`
	Username      *string           `json:"username"`
	DisplayName   string            `json:"display_name"`
	AvatarURL     *string           `json:"avatar_url"`
	CreatedAt     unixtime.UnixTime `json:"created_at"`
}

func NewBlockResponse(block domain.Block) BlockResponse {
	return BlockResponse{
		BlockedUserID: block.BlockedID,
		CreatedAt:     unixtime.New(block.CreatedAt),
	}
}

func NewUnblockResponse(blockedID uuid.UUID) UnblockResponse {
	return UnblockResponse{
		UnblockedUserID: blockedID,
	}
}

func NewBlockedUserResponse(item domain.BlockedUser) BlockedUserResponse {
	return BlockedUserResponse{
		BlockedUserID: item.UserID,
		Username:      item.Username,
		DisplayName:   item.DisplayName,
		AvatarURL:     item.AvatarURL,
		CreatedAt:     unixtime.New(item.CreatedAt),
	}
}
