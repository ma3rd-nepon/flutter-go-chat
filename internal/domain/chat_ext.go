package domain

type ChatView struct {
	Chat

	MemberCount int
	IsPinned    bool
	MyRole      ChatMemberRole
	UnreadCount int
	IsMember    bool
}
