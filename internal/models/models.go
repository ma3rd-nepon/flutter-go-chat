package models

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID           uuid.UUID  `gorm:"type:uuid;primaryKey" json:"id"`
	Username     string     `json:"username"`
	DisplayName  *string    `json:"display_name" gorm:"column:display_name"`
	Phone        *string    `json:"phone"`
	AvatarURL    *string    `json:"avatar_url"`
	Bio          *string    `json:"bio"`
	PasswordHash string     `json:"-" gorm:"column:password_hash"`
	LastSeen     *time.Time `json:"last_seen"`
	CreatedAt    time.Time  `json:"created_at"`
}

func (User) TableName() string {
	return "users"
}

type Chat struct {
	ID              uuid.UUID  `gorm:"type:uuid;primaryKey" json:"id"`
	Name            *string    `json:"name"`
	ChatType        string     `json:"type" gorm:"column:chat_type"`
	PinnedMessageID *uuid.UUID `json:"pinned_message_id"`
	CreatedAt       time.Time  `json:"created_at"`
}

func (Chat) TableName() string {
	return "chats"
}

type Message struct {
	ID        uuid.UUID  `gorm:"type:uuid;primaryKey" json:"id"`
	ChatID    uuid.UUID  `json:"chat_id"`
	SenderID  uuid.UUID  `json:"sender_id"`
	Type      string     `json:"type"`
	Text      *string    `json:"text"`
	MediaURL  *string    `json:"media_url"`
	ReplyToID *uuid.UUID `json:"reply_to_id"`
	Status    string     `json:"status" gorm:"default:sent"`
	IsDeleted bool       `json:"is_deleted" gorm:"column:is_deleted"`
	EditedAt  *time.Time `json:"edited_at"`
	CreatedAt time.Time  `json:"created_at"`
}

func (Message) TableName() string {
	return "messages"
}

type ChatMember struct {
	ChatID            uuid.UUID  `gorm:"type:uuid;primaryKey" json:"chat_id"`
	UserID            uuid.UUID  `gorm:"type:uuid;primaryKey" json:"user_id"`
	Role              string     `json:"role"`
	LastReadMessageID *uuid.UUID `json:"last_read_message_id"`
	MutedUntil        *time.Time `json:"muted_until"`
	IsPinned          bool       `json:"is_pinned"`
	JoinedAt          time.Time  `json:"joined_at"`
}

func (ChatMember) TableName() string {
	return "chat_members"
}

type MessageStatus struct {
	MessageID uuid.UUID `gorm:"type:uuid;primaryKey" json:"message_id"`
	UserID    uuid.UUID `gorm:"type:uuid;primaryKey" json:"user_id"`
	Status    string    `json:"status"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (MessageStatus) TableName() string {
	return "message_status"
}

type MessageReaction struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	MessageID uuid.UUID `gorm:"type:uuid;not null" json:"message_id"`
	UserID    uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	Emoji     string    `gorm:"size:10;not null" json:"emoji"`
	CreatedAt time.Time `gorm:"default:CURRENT_TIMESTAMP" json:"created_at"`
}
