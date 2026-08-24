package ws

import (
	"time"

	"github.com/google/uuid"
)

type Event struct {
	Event     string         `json:"event"`
	ChatID    *uuid.UUID     `json:"chat_id"`
	Data      map[string]any `json:"data"`
	Timestamp int64          `json:"timestamp"`
}

func NewEvent(name string, chatID *uuid.UUID, data map[string]any) Event {
	if data == nil {
		data = map[string]any{}
	}

	return Event{
		Event:     name,
		ChatID:    chatID,
		Data:      data,
		Timestamp: time.Now().UTC().Unix(),
	}
}

const (
	EventNewMessage       = "new_message"
	EventMessageUpdated   = "message_updated"
	EventMessageDeleted   = "message_deleted"
	EventReactionAdded    = "reaction_added"
	EventReactionRemoved  = "reaction_removed"
	EventChatCreated      = "chat_created"
	EventChatUpdated      = "chat_updated"
	EventChatDeleted      = "chat_deleted"
	EventMemberAdded      = "member_added"
	EventMemberRemoved    = "member_removed"
	EventTypingStart      = "typing_start"
	EventTypingStop       = "typing_stop"
	EventPresenceChanged  = "presence_changed"
	EventNotification     = "notification_created"
	EventFriendRequest    = "friend_request"
	EventFriendAccepted   = "friend_accepted"
	EventVoiceStateUpdate = "voice_state_updated"
	EventConnected        = "connected"
)
