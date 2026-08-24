CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TYPE user_status AS ENUM ('online','offline','invisible','dnd');
CREATE TYPE chat_type AS ENUM ('private','group','channel');
CREATE TYPE chat_member_role AS ENUM ('owner','admin','member');
CREATE TYPE message_kind AS ENUM ('text','image','file','voice','system');
CREATE TYPE friend_status AS ENUM ('pending','accepted','declined');
CREATE TYPE notification_type AS ENUM ('message','mention','friend_request','friend_accepted','chat_invite','system');

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email CITEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  username CITEXT UNIQUE,
  display_name TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  banner_url TEXT,
  theme TEXT,
  status user_status NOT NULL DEFAULT 'offline',
  quote TEXT,
  music TEXT,
  last_seen TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (char_length(display_name) BETWEEN 1 AND 64),
  CHECK (username IS NULL OR char_length(username) BETWEEN 3 AND 32),
  CHECK (bio IS NULL OR char_length(bio) <= 500),
  CHECK (quote IS NULL OR char_length(quote) <= 160),
  CHECK (music IS NULL OR char_length(music) <= 160)
);

CREATE TABLE blocks (
  blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id),
  CHECK (blocker_id <> blocked_id)
);

CREATE TABLE friends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  addressee_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status friend_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (requester_id, addressee_id),
  CHECK (requester_id <> addressee_id)
);

CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type chat_type NOT NULL,
  title TEXT,
  description TEXT,
  avatar_url TEXT,
  theme TEXT,
  owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
  pinned_message_id UUID,
  last_message_id UUID,
  last_message_at TIMESTAMPTZ,
  allow_member_invite BOOLEAN NOT NULL DEFAULT true,
  allow_member_edit_info BOOLEAN NOT NULL DEFAULT false,
  allow_member_send_messages BOOLEAN NOT NULL DEFAULT true,
  slow_mode_seconds INTEGER NOT NULL DEFAULT 0 CHECK (slow_mode_seconds >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (type = 'private' OR title IS NOT NULL),
  CHECK (title IS NULL OR char_length(title) BETWEEN 1 AND 64),
  CHECK (description IS NULL OR char_length(description) <= 500)
);

CREATE TABLE attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  uploader_id UUID REFERENCES users(id) ON DELETE SET NULL,
  url TEXT NOT NULL,
  filename TEXT NOT NULL,
  mime_type TEXT NOT NULL,
  size_bytes BIGINT NOT NULL CHECK (size_bytes >= 0),
  kind message_kind NOT NULL DEFAULT 'file',
  width INT,
  height INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE chat_members (
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role chat_member_role NOT NULL DEFAULT 'member',
  is_pinned BOOLEAN NOT NULL DEFAULT false,
  muted_until TIMESTAMPTZ,
  restricted_until TIMESTAMPTZ,
  restricted_by UUID REFERENCES users(id) ON DELETE SET NULL,
  restricted_reason TEXT,
  last_read_message_id UUID,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (chat_id, user_id)
);

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
  kind message_kind NOT NULL DEFAULT 'text',
  text TEXT,
   attachment_url TEXT,
  attachment_id UUID,
  reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  forwarded_from_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  is_edited BOOLEAN NOT NULL DEFAULT false,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  is_pinned BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  CHECK (kind = 'system' OR text IS NOT NULL OR attachment_url IS NOT NULL),
  CHECK ((is_deleted = false) OR (is_deleted = true AND deleted_at IS NOT NULL)),
  CHECK (text IS NULL OR char_length(text) <= 4096)
);

ALTER TABLE messages
  ADD CONSTRAINT fk_messages_attachment
  FOREIGN KEY (attachment_id) REFERENCES attachments(id) ON DELETE SET NULL;
ALTER TABLE chats
  ADD CONSTRAINT fk_chats_last_message
  FOREIGN KEY (last_message_id) REFERENCES messages(id) ON DELETE SET NULL;
ALTER TABLE chats
  ADD CONSTRAINT fk_chats_pinned_message
  FOREIGN KEY (pinned_message_id) REFERENCES messages(id) ON DELETE SET NULL;
ALTER TABLE chat_members
  ADD CONSTRAINT fk_chat_members_last_read
  FOREIGN KEY (last_read_message_id) REFERENCES messages(id) ON DELETE SET NULL;

CREATE TABLE reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  emoji TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (message_id, user_id, emoji),
  CHECK (char_length(emoji) BETWEEN 1 AND 32)
);

CREATE TABLE voice_channels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  bitrate INTEGER NOT NULL DEFAULT 64000 CHECK (bitrate BETWEEN 8000 AND 384000),
  max_participants INTEGER CHECK (max_participants IS NULL OR max_participants > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (char_length(name) BETWEEN 1 AND 64)
);

CREATE TABLE voice_participants (
  channel_id UUID NOT NULL REFERENCES voice_channels(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  muted BOOLEAN NOT NULL DEFAULT false,
  deafened BOOLEAN NOT NULL DEFAULT false,
  PRIMARY KEY (channel_id, user_id)
);

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type notification_type NOT NULL,
  actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  message_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  user_agent TEXT,
  ip INET,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE chat_bans (
  chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  banned_by UUID REFERENCES users(id) ON DELETE SET NULL,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (chat_id, user_id)
);

CREATE OR REPLACE FUNCTION check_chat_ban() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM chat_bans WHERE chat_id = NEW.chat_id AND user_id = NEW.user_id) THEN
    RAISE EXCEPTION 'user is banned in this chat';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_chat_ban
BEFORE INSERT ON chat_members
FOR EACH ROW EXECUTE FUNCTION check_chat_ban();

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_username_trgm ON users USING gin (username gin_trgm_ops);
CREATE INDEX idx_users_display_name_trgm ON users USING gin (display_name gin_trgm_ops);
CREATE INDEX idx_friends_requester ON friends(requester_id);
CREATE INDEX idx_friends_addressee ON friends(addressee_id);
CREATE INDEX idx_friends_status ON friends(status);
CREATE INDEX idx_chat_members_user ON chat_members(user_id);
CREATE INDEX idx_chat_members_chat ON chat_members(chat_id);
CREATE INDEX idx_chat_members_pinned ON chat_members(user_id, is_pinned);
CREATE INDEX idx_chats_title_trgm ON chats USING gin (title gin_trgm_ops);
CREATE INDEX idx_chats_last_message_at ON chats(last_message_at DESC);
CREATE INDEX idx_messages_chat_created ON messages(chat_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_reply ON messages(reply_to_id);
CREATE INDEX idx_attachments_chat ON attachments(chat_id);
CREATE INDEX idx_reactions_message ON reactions(message_id);
CREATE INDEX idx_reactions_user ON reactions(user_id);
CREATE INDEX idx_voice_channels_chat ON voice_channels(chat_id);
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, read_at);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at);