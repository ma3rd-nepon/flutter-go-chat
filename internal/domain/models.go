package domain

import (
	"time"

	"github.com/google/uuid"
)

type UserStatus string

const (
	UserStatusOnline    UserStatus = "online"
	UserStatusOffline   UserStatus = "offline"
	UserStatusInvisible UserStatus = "invisible"
	UserStatusDND       UserStatus = "dnd"
)

type ChatType string

const (
	ChatTypePrivate ChatType = "private"
	ChatTypeGroup   ChatType = "group"
	ChatTypeChannel ChatType = "channel"
)

type ChatMemberRole string

const (
	ChatMemberRoleOwner  ChatMemberRole = "owner"
	ChatMemberRoleAdmin  ChatMemberRole = "admin"
	ChatMemberRoleMember ChatMemberRole = "member"
)

type MessageKind string

const (
	MessageKindText   MessageKind = "text"
	MessageKindImage  MessageKind = "image"
	MessageKindFile   MessageKind = "file"
	MessageKindVoice  MessageKind = "voice"
	MessageKindSystem MessageKind = "system"
)

type FriendStatus string

const (
	FriendStatusPending  FriendStatus = "pending"
	FriendStatusAccepted FriendStatus = "accepted"
	FriendStatusDeclined FriendStatus = "declined"
)

type NotificationType string

const (
	NotificationTypeMessage        NotificationType = "message"
	NotificationTypeMention        NotificationType = "mention"
	NotificationTypeFriendRequest  NotificationType = "friend_request"
	NotificationTypeFriendAccepted NotificationType = "friend_accepted"
	NotificationTypeChatInvite     NotificationType = "chat_invite"
	NotificationTypeSystem         NotificationType = "system"
)

type User struct {
	ID           uuid.UUID
	Email        string
	PasswordHash string

	Username    *string
	DisplayName string

	Bio       *string
	AvatarURL *string
	BannerURL *string
	Theme     *string

	Status UserStatus

	Quote *string
	Music *string

	LastSeen *time.Time

	CreatedAt time.Time
	UpdatedAt time.Time
}

type Chat struct {
	ID          uuid.UUID
	Type        ChatType
	Title       *string
	Description *string
	AvatarURL   *string
	Theme       *string
	OwnerID     *uuid.UUID
	PinnedMessageID *uuid.UUID
	LastMessageID *uuid.UUID
	LastMessageAt *time.Time
	AllowMemberInvite       bool
	AllowMemberEditInfo     bool
	AllowMemberSendMessages bool
	SlowModeSeconds         int
	CreatedAt time.Time
	UpdatedAt time.Time
}

type ChatMember struct {
	ChatID           uuid.UUID
	UserID           uuid.UUID
	RestrictedUntil  *time.Time
	RestrictedBy     *uuid.UUID
	RestrictedReason *string
	Role             ChatMemberRole

	IsPinned   bool
	MutedUntil *time.Time

	LastReadMessageID *uuid.UUID

	JoinedAt time.Time
}

type Message struct {
	ID              uuid.UUID
	ChatID          uuid.UUID
	SenderID        *uuid.UUID
	Kind            MessageKind
	Text            *string
	AttachmentURL   *string
	AttachmentID    *uuid.UUID
	ReplyToID       *uuid.UUID
	ForwardedFromID *uuid.UUID
	IsEdited        bool
	IsDeleted       bool
	IsPinned        bool
	CreatedAt       time.Time
	UpdatedAt       time.Time
	DeletedAt       *time.Time
}

type Reaction struct {
	ID        uuid.UUID
	MessageID uuid.UUID
	UserID    uuid.UUID
	Emoji     string
	CreatedAt time.Time
}

type VoiceChannel struct {
	ID              uuid.UUID
	ChatID          uuid.UUID
	Name            string
	Bitrate         int
	MaxParticipants *int
	CreatedAt       time.Time
	UpdatedAt       time.Time
}

type VoiceParticipant struct {
	ChannelID uuid.UUID
	UserID    uuid.UUID
	JoinedAt  time.Time
	Muted     bool
	Deafened  bool
}

type Friend struct {
	ID          uuid.UUID
	RequesterID uuid.UUID
	AddresseeID uuid.UUID
	Status      FriendStatus
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

type Notification struct {
	ID        uuid.UUID
	UserID    uuid.UUID
	Type      NotificationType
	ActorID   *uuid.UUID
	ChatID    *uuid.UUID
	MessageID *uuid.UUID
	Payload   map[string]any
	ReadAt    *time.Time
	CreatedAt time.Time
}

type RefreshToken struct {
	ID        uuid.UUID
	UserID    uuid.UUID
	TokenHash string

	UserAgent *string
	IP        *string

	ExpiresAt time.Time
	RevokedAt *time.Time

	CreatedAt time.Time
}
