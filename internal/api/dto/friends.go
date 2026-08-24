package dto

import (
	"github.com/google/uuid"

	"supernova/internal/domain"
	"supernova/internal/pkg/unixtime"
)

type FriendUserRequest struct {
	UserID uuid.UUID `json:"user_id"`
}

type FriendResponse struct {
	ID          uuid.UUID         `json:"id"`
	RequesterID uuid.UUID         `json:"requester_id"`
	AddresseeID uuid.UUID         `json:"addressee_id"`
	Status      string            `json:"status"`
	CreatedAt   unixtime.UnixTime `json:"created_at"`
	UpdatedAt   unixtime.UnixTime `json:"updated_at"`
}

type FriendUserShort struct {
	ID          uuid.UUID `json:"id"`
	Username    *string   `json:"username"`
	DisplayName string    `json:"display_name"`
	AvatarURL   *string   `json:"avatar_url"`
}

type FriendListItemResponse struct {
	ID        uuid.UUID         `json:"id"`
	User      FriendUserShort   `json:"user"`
	Status    string            `json:"status"`
	CreatedAt unixtime.UnixTime `json:"created_at"`
	UpdatedAt unixtime.UnixTime `json:"updated_at"`
}

func NewFriendResponse(f domain.Friend) FriendResponse {
	return FriendResponse{
		ID:          f.ID,
		RequesterID: f.RequesterID,
		AddresseeID: f.AddresseeID,
		Status:      string(f.Status),
		CreatedAt:   unixtime.New(f.CreatedAt),
		UpdatedAt:   unixtime.New(f.UpdatedAt),
	}
}

func NewFriendListItemResponse(item domain.FriendUser) FriendListItemResponse {
	return FriendListItemResponse{
		ID: item.FriendID,
		User: FriendUserShort{
			ID:          item.UserID,
			Username:    item.Username,
			DisplayName: item.DisplayName,
			AvatarURL:   item.AvatarURL,
		},
		Status:    string(item.Status),
		CreatedAt: unixtime.New(item.CreatedAt),
		UpdatedAt: unixtime.New(item.UpdatedAt),
	}
}
