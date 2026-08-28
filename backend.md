# 📡 Messenger Backend API & Database Schema

Полная документация по API эндпоинтам, форматам ответов, моделям данных и SQL-схеме базы данных PostgreSQL для мессенджера.

---

## 📑 Оглавление
1. [API Endpoints](#1-api-endpoints)
2. [Форматы ответов](#2-форматы-ответов)
3. [WebSocket](#3-websocket)
4. [Модели данных (Data Models)](#4-модели-данных-data-models)
5. [SQL Схема (PostgreSQL)](#5-sql-схема-postgresql)

---

## 1. 🌐 API Endpoints

### 🔐 1.1 Auth (Аутентификация)
| Метод | Путь | Описание |
| :--- | :--- | :--- |
| `POST` | `/auth/register` | Регистрация нового пользователя |
| `POST` | `/auth/login` | Вход в систему |
| `POST` | `/auth/logout` | Выход из системы |
| `POST` | `/auth/refresh` | Обновление токена доступа |

### 💬 1.2 Chats (Чаты)
| Метод | Путь | Описание |
| :--- | :--- | :--- |
| `POST` | `/chats` | Создание нового чата |
| `GET` | `/chats` | Получение списка чатов |
| `GET` | `/chats/search` | Поиск чатов |
| `GET` | `/chats/{chatID}` | Получение информации о чате |
| `PATCH` | `/chats/{chatID}` | Обновление информации о чате |
| `DELETE` | `/chats/{chatID}` | Удаление чата |
| `PATCH` | `/chats/{chatID}/settings` | Изменение настроек чата |
| `POST` | `/chats/{chatID}/pin` | Закрепить чат |
| `POST` | `/chats/{chatID}/unpin` | Открепить чат |
| `POST` | `/chats/{chatID}/members` | Добавить участников в чат |
| `DELETE` | `/chats/{chatID}/members/{userID}` | Удалить участника из чата |

### 📨 1.3 Messages (Сообщения)
| Метод | Путь | Описание |
| :--- | :--- | :--- |
| `GET` | `/chats/{chatID}/messages` | Получение истории сообщений |
| `POST` | `/chats/{chatID}/messages` | Отправка нового сообщения |
| `PATCH` | `/messages/{messageID}` | Редактирование сообщения |
| `DELETE` | `/messages/{messageID}` | Удаление сообщения |
| `POST` | `/messages/{messageID}/reactions` | Добавить реакцию на сообщение |
| `DELETE` | `/messages/{messageID}/reactions/{emoji}` | Удалить реакцию с сообщения |
| `POST` | `/chats/{chatID}/read` | Отметить сообщения в чате как прочитанные |

### 🚫 1.4 Blocks (Блокировки)
| Метод | Путь | Описание |
| :--- | :--- | :--- |
| `POST` | `/block` | Заблокировать пользователя |
| `POST` | `/unblock` | Разблокировать пользователя |
| `GET` | `/blocks` | Получить список заблокированных пользователей |

### 👥 1.5 Friends (Друзья)
| Метод | Путь | Описание |
| :--- | :--- | :--- |
| `POST` | `/friends/request` | Отправить заявку в друзья |
| `POST` | `/friends/accept` | Принять заявку в друзья |
| `POST` | `/friends/reject` | Отклонить заявку в друзья |
| `POST` | `/friends/remove` | Удалить из друзей |
| `GET` | `/friends` | Получить список друзей |
| `GET` | `/friends/requests` | Получить входящие заявки в друзья |

### 📤 1.6 Uploads (Загрузка файлов)
| Метод | Путь | Описание |
| :--- | :--- | :--- |
| `POST` | `/uploads/avatar` | Загрузка аватара пользователя |
| `POST` | `/uploads/banner` | Загрузка баннера пользователя |
| `POST` | `/chats/{chatID}/avatar` | Загрузка аватара чата |
| `POST` | `/chats/{chatID}/attachments` | Загрузка вложений в чат |

### 🎙️ 1.7 Voice (Голосовые каналы)
| Метод | Путь | Описание |
| :--- | :--- | :--- |
| `POST` | `/voice/channels` | Создание голосового канала |
| `GET` | `/voice/channels/{channelID}` | Информация о голосовом канале |
| `POST` | `/voice/channels/{channelID}/join` | Присоединиться к каналу |
| `POST` | `/voice/channels/{channelID}/leave` | Покинуть канал |

### 🔔 1.8 Notifications (Уведомления)
| Метод | Путь | Описание |
| :--- | :--- | :--- |
| `GET` | `/notifications` | Получение списка уведомлений |
| `POST` | `/notifications/read` | Отметить уведомление как прочитанное |
| `POST` | `/notifications/read-all` | Отметить все уведомления как прочитанные |

### 🔌 1.9 WebSocket (Внутренняя структура)
- `internal/ws/hub.go`
- `internal/ws/client.go`
- `internal/ws/events.go`
- `internal/ws/handler.go`

---

## 2. 📦 Форматы ответов

### 2.1 Успешный ответ
```json
{
  "success": true,
  "data": {},
  "error": null,
  "meta": {
    "request_id": "req_01J8Z",
    "timestamp": 1783150420
  }
}
```

### 2.2 Ответ с ошибкой
```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "validation_error",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "issue": "invalid email format" }
    ]
  },
  "meta": {
    "request_id": "req_01J8Z",
    "timestamp": 1783150420
  }
}
```

### 2.3 Коды ошибок
> `validation_error` • `unauthorized` • `forbidden` • `not_found` • `conflict` • `rate_limited` • `internal_error` • `invalid_credentials` • `token_expired` • `token_invalid` • `file_too_large` • `unsupported_media_type`

### 2.4 Пагинация (Cursor-based)
```json
{
  "success": true,
  "data": {
    "items": [],
    "pagination": {
      "limit": 20,
      "cursor": null,
      "has_more": false
    }
  },
  "error": null,
  "meta": { "request_id": "req_01J8Z", "timestamp": 1783150420 }
}
```

---

## 3. 🔌 WebSocket

### 3.1 Структура события
| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `event` | `string` | Название события (например, `new_message`) |
| `chat_id` | `uuid \| null` | ID чата, к которому относится событие |
| `data` | `object` | Полезная нагрузка события |
| `timestamp` | `int64` | Unix-время в секундах |

### 3.2 Пример события
```json
{
  "event": "new_message",
  "chat_id": "11111111-1111-7111-8111-111111111111",
  "data": {
    "message": {
      "id": "22222222-2222-7222-8222-222222222222",
      "chat_id": "11111111-1111-7111-8111-111111111111",
      "sender_id": "33333333-3333-7333-8333-333333333333",
      "kind": "text",
      "text": "Hello",
      "created_at": 1783150420,
      "updated_at": 1783150420,
      "deleted_at": null
    }
  },
  "timestamp": 1783150420
}
```

---

## 4. 🗂️ Модели данных (Data Models)

### 4.1 User
| Поле | Тип | Ограничения |
| :--- | :--- | :--- |
| `id` | `uuid` | PRIMARY KEY |
| `email` | `string` | UNIQUE, NOT NULL |
| `password_hash` | `string` | NOT NULL |
| `username` | `string \| null` | UNIQUE, OPTIONAL |
| `display_name` | `string` | NOT NULL, NOT UNIQUE |
| `bio` | `string \| null` | |
| `avatar_url` | `string \| null` | |
| `banner_url` | `string \| null` | |
| `accent_color` | `string \| null` | HEX color |
| `status` | `enum` | `online` \| `offline` \| `invisible` \| `dnd` |
| `quote` | `string \| null` | |
| `music` | `string \| null` | |
| `last_seen` | `int64 \| null` | |
| `created_at` | `int64` | |
| `updated_at` | `int64` | |

<details>
<summary>📄 Пример User JSON</summary>

```json
{
  "id": "33333333-3333-7333-8333-333333333333",
  "username": "Danil",
  "display_name": "Danil",
  "email": "Danil@example.com", // Только для /users/me
  "bio": "Frontend witch",
  "avatar_url": "/uploads/avatars/33333333-3333-7333-8333-333333333333.png",
  "banner_url": "/uploads/banners/33333333-3333-7333-8333-333333333333.png",
  "accent_color": "#7C3AED",
  "status": "online",
  "quote": "ship it",
  "music": "Dekma",
  "last_seen": null,
  "created_at": 1783150420,
  "updated_at": 1783150420
}
```
</details>

### 4.2 Chat
| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `id` | `uuid` | |
| `type` | `enum` | `private` \| `group` \| `channel` |
| `title` | `string \| null` | |
| `description` | `string \| null` | |
| `avatar_url` | `string \| null` | |
| `accent_color` | `string \| null` | |
| `owner_id` | `uuid \| null` | |
| `last_message_id` | `uuid \| null` | |
| `last_message_at` | `int64 \| null` | |
| `allow_member_invite` | `bool` | |
| `allow_member_edit_info` | `bool` | |
| `allow_member_send_messages`| `bool` | |
| `slow_mode_seconds` | `int` | |
| `member_count` | `int` | |
| `is_pinned` | `bool` | |
| `my_role` | `enum` | `owner` \| `admin` \| `member` |
| `unread_count` | `int` | |
| `created_at` / `updated_at`| `int64` | |

### 4.3 Message
| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `id` | `uuid` | |
| `chat_id` | `uuid` | |
| `sender_id` | `uuid \| null` | |
| `kind` | `enum` | `text` \| `image` \| `file` \| `voice` \| `system` |
| `text` | `string \| null` | |
| `attachment_url` | `string \| null` | |
| `reply_to_id` | `uuid \| null` | |
| `forwarded_from_id`| `uuid \| null` | |
| `is_edited` | `bool` | |
| `is_deleted` | `bool` | |
| `is_pinned` | `bool` | |
| `reactions` | `ReactionSummary[]`| См. ниже |
| `created_at` / `updated_at` / `deleted_at` | `int64` | |

**ReactionSummary**: `{ "emoji": "🔥", "count": 2, "reacted_by_me": true }`

### 4.4 Reaction
> ⚠️ **ВАЖНО**: Ограничение `UNIQUE(message_id, user_id, emoji)`

| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `id` | `uuid` | |
| `message_id` | `uuid` | |
| `user_id` | `uuid` | |
| `emoji` | `string` | |
| `created_at` | `int64` | |

### 4.5 VoiceChannel & VoiceParticipant
**VoiceChannel**: `id`, `chat_id`, `name`, `bitrate` (int), `max_participants` (int \| null), `participant_count` (int), `participants` (VoiceParticipant[]), `created_at`, `updated_at`.
**VoiceParticipant**: `user_id`, `joined_at`, `muted` (bool), `deafened` (bool).

### 4.6 Friend
> ⚠️ **ВАЖНО**: `UNIQUE(requester_id, addressee_id)` и `CHECK(requester_id <> addressee_id)`

| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `id` | `uuid` | |
| `requester_id` | `uuid` | |
| `addressee_id` | `uuid` | |
| `status` | `enum` | `pending` \| `accepted` \| `declined` |
| `created_at` / `updated_at`| `int64` | |

### 4.7 Notification
| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `id` | `uuid` | |
| `user_id` | `uuid` | |
| `type` | `enum` | `message` \| `mention` \| `friend_request` \| `friend_accepted` \| `chat_invite` \| `system` |
| `actor_id` | `uuid \| null` | |
| `chat_id` | `uuid \| null` | |
| `message_id` | `uuid \| null` | |
| `payload` | `json` | |
| `read_at` | `int64 \| null` | |
| `created_at` | `int64` | |

### 4.8 Block
> ⚠️ **ВАЖНО**: `PRIMARY KEY(blocker_id, blocked_id)` и `CHECK(blocker_id <> blocked_id)`

| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `blocker_id` | `uuid` | |
| `blocked_id` | `uuid` | |
| `created_at` | `int64` | |

### 4.9 ChatMember
| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `chat_id` | `uuid` | |
| `user_id` | `uuid` | |
| `role` | `enum` | `owner` \| `admin` \| `member` |
| `is_pinned` | `bool` | |
| `muted` | `bool` | |
| `last_read_message_id`| `uuid \| null` | |
| `joined_at` | `int64` | |

### 4.10 RefreshToken
| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `id` | `uuid` | |
| `user_id` | `uuid` | |
| `token_hash` | `string` | UNIQUE |
| `user_agent` | `string \| null` | |
| `ip` | `string \| null` | |
| `expires_at` | `int64` | |
| `revoked_at` | `int64 \| null` | |
| `created_at` | `int64` | |

---

## 5. 🗄️ SQL Схема (PostgreSQL)

### 5.1 Расширения и Типы
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TYPE user_status AS ENUM ('online', 'offline', 'invisible', 'dnd');
CREATE TYPE chat_type AS ENUM ('private', 'group', 'channel');
CREATE TYPE chat_member_role AS ENUM ('owner', 'admin', 'member');
CREATE TYPE message_kind AS ENUM ('text', 'image', 'file', 'voice', 'system');
CREATE TYPE friend_status AS ENUM ('pending', 'accepted', 'declined');
CREATE TYPE notification_type AS ENUM ('message', 'mention', 'friend_request', 'friend_accepted', 'chat_invite', 'system');
```

### 5.2 Таблицы
<details>
<summary>📄 users</summary>

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email CITEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    username CITEXT UNIQUE,
    display_name TEXT NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    banner_url TEXT,
    accent_color TEXT CHECK (accent_color IS NULL OR accent_color ~ '^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$'),
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
```
</details>

<details>
<summary>📄 chats & chat_members</summary>

```sql
CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type chat_type NOT NULL,
    title TEXT,
    description TEXT,
    avatar_url TEXT,
    accent_color TEXT CHECK (accent_color IS NULL OR accent_color ~ '^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$'),
    owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
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

CREATE TABLE chat_members (
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role chat_member_role NOT NULL DEFAULT 'member',
    is_pinned BOOLEAN NOT NULL DEFAULT false,
    muted BOOLEAN NOT NULL DEFAULT false,
    last_read_message_id UUID,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (chat_id, user_id)
);
```
</details>

<details>
<summary>📄 messages & reactions</summary>

```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE SET NULL,
    kind message_kind NOT NULL DEFAULT 'text',
    text TEXT,
    attachment_url TEXT,
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

CREATE TABLE reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    emoji TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (message_id, user_id, emoji),
    CHECK (char_length(emoji) BETWEEN 1 AND 32)
);
```
</details>

<details>
<summary>📄 friends & blocks</summary>

```sql
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

CREATE TABLE blocks (
    blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (blocker_id, blocked_id),
    CHECK (blocker_id <> blocked_id)
);
```
</details>

<details>
<summary>📄 voice_channels & voice_participants</summary>

```sql
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
```
</details>

<details>
<summary>📄 notifications & refresh_tokens</summary>

```sql
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
```
</details>

### 5.3 Внешние ключи (Foreign Keys)
```sql
ALTER TABLE chats ADD CONSTRAINT fk_chats_last_message 
    FOREIGN KEY (last_message_id) REFERENCES messages(id) ON DELETE SET NULL;

ALTER TABLE chat_members ADD CONSTRAINT fk_chat_members_last_read 
    FOREIGN KEY (last_read_message_id) REFERENCES messages(id) ON DELETE SET NULL;
```

### 5.4 Индексы (Indexes)
```sql
-- Users
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_username_trgm ON users USING gin (username gin_trgm_ops);
CREATE INDEX idx_users_display_name_trgm ON users USING gin (display_name gin_trgm_ops);

-- Friends
CREATE INDEX idx_friends_requester ON friends(requester_id);
CREATE INDEX idx_friends_addressee ON friends(addressee_id);
CREATE INDEX idx_friends_status ON friends(status);

-- Chats & Members
CREATE INDEX idx_chat_members_user ON chat_members(user_id);
CREATE INDEX idx_chat_members_chat ON chat_members(chat_id);
CREATE INDEX idx_chat_members_pinned ON chat_members(user_id, is_pinned);
CREATE INDEX idx_chats_title_trgm ON chats USING gin (title gin_trgm_ops);
CREATE INDEX idx_chats_last_message_at ON chats(last_message_at DESC);

-- Messages & Reactions
CREATE INDEX idx_messages_chat_created ON messages(chat_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_reply ON messages(reply_to_id);
CREATE INDEX idx_reactions_message ON reactions(message_id);
CREATE INDEX idx_reactions_user ON reactions(user_id);

-- Voice & Notifications & Tokens
CREATE INDEX idx_voice_channels_chat ON voice_channels(chat_id);
CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, read_at);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at);
```

### 5.5 Триггеры (Triggers)
```sql
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_friends_updated_at BEFORE UPDATE ON friends FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_chats_updated_at BEFORE UPDATE ON chats FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_messages_updated_at BEFORE UPDATE ON messages FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_voice_channels_updated_at BEFORE UPDATE ON voice_channels FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

---
> 💡 *Документация сгенерирована для удобства разработки и поддержки backend-части мессенджера. При изменении схем не забывайте обновлять этот файл.*
