package models

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID           uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Username     *string    `gorm:"uniqueIndex;size:50;default:null" json:"username"`
	DisplayName  *string    `gorm:"size:100;default:null" json:"display_name" gorm:"column:display_name"`
	Phone        *string    `gorm:"uniqueIndex;size:20;default:null" json:"phone"`
	AvatarURL    *string    `gorm:"size:255;default:null" json:"avatar_url"`
	Bio          *string    `gorm:"type:text;default:null" json:"bio"`
	PasswordHash string     `json:"-" gorm:"column:password_hash;not null"`
	LastSeen     *time.Time `gorm:"default:null" json:"last_seen"`
	CreatedAt    time.Time  `gorm:"default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt    time.Time  `gorm:"default:CURRENT_TIMESTAMP" json:"updated_at"`
}

func (User) TableName() string {
	return "users"
}

type Chat struct {
	ID              uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Name            *string    `gorm:"size:100;default:null" json:"name"`
	ChatType        string     `gorm:"size:20;not null;default:'private'" json:"type" gorm:"column:chat_type"`
	PinnedMessageID *uuid.UUID `gorm:"type:uuid;default:null" json:"pinned_message_id"`
	CreatedAt       time.Time  `gorm:"default:CURRENT_TIMESTAMP" json:"created_at"`
	UpdatedAt       time.Time  `gorm:"default:CURRENT_TIMESTAMP;index" json:"updated_at"`
}

func (Chat) TableName() string {
	return "chats"
}

type Message struct {
	ID        uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	ChatID    uuid.UUID  `gorm:"type:uuid;not null;index" json:"chat_id"`
	SenderID  uuid.UUID  `gorm:"type:uuid;not null;index" json:"sender_id"`
	Type      string     `gorm:"size:20;not null;default:'text'" json:"type"`
	Text      *string    `gorm:"type:text;default:null" json:"text"`
	MediaURL  *string    `gorm:"size:255;default:null" json:"media_url"`
	ReplyToID *uuid.UUID `gorm:"type:uuid;default:null" json:"reply_to_id"`
	Status    string     `gorm:"size:20;not null;default:'sent'" json:"status"`
	IsDeleted bool       `gorm:"default:false" json:"is_deleted" gorm:"column:is_deleted"`
	EditedAt  *time.Time `gorm:"default:null" json:"edited_at"`
	CreatedAt time.Time  `gorm:"default:CURRENT_TIMESTAMP" json:"created_at"`
}

func (Message) TableName() string {
	return "messages"
}

type ChatMember struct {
	ChatID            uuid.UUID  `gorm:"type:uuid;primaryKey;index" json:"chat_id"`
	UserID            uuid.UUID  `gorm:"type:uuid;primaryKey;index" json:"user_id"`
	Role              string     `gorm:"size:20;not null;default:'member'" json:"role"`
	LastReadMessageID *uuid.UUID `gorm:"type:uuid;default:null" json:"last_read_message_id"`
	MutedUntil        *time.Time `gorm:"default:null" json:"muted_until"`
	IsPinned          bool       `gorm:"default:false" json:"is_pinned"`
	JoinedAt          time.Time  `gorm:"default:CURRENT_TIMESTAMP" json:"joined_at"`
}

func (ChatMember) TableName() string {
	return "chat_members"
}

type MessageStatus struct {
	MessageID uuid.UUID `gorm:"type:uuid;primaryKey;index" json:"message_id"`
	UserID    uuid.UUID `gorm:"type:uuid;primaryKey;index" json:"user_id"`
	Status    string    `gorm:"size:20;not null" json:"status"`
	UpdatedAt time.Time `gorm:"default:CURRENT_TIMESTAMP" json:"updated_at"`
}

func (MessageStatus) TableName() string {
	return "message_status"
}

type MessageReaction struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	MessageID uuid.UUID `gorm:"type:uuid;not null;index" json:"message_id"`
	UserID    uuid.UUID `gorm:"type:uuid;not null;index" json:"user_id"`
	Emoji     string    `gorm:"size:10;not null" json:"emoji"`
	CreatedAt time.Time `gorm:"default:CURRENT_TIMESTAMP" json:"created_at"`
}
