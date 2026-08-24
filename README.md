<h1 align="center">Supernova</h1>

<p align="center">
  <b>Backend SN</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white" alt="Go" />
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/WebSocket-010101?style=for-the-badge&logo=socketdotio&logoColor=white" alt="WebSocket" />
  <img src="https://img.shields.io/badge/JWT-000000?style=for-the-badge&logo=jsonwebtokens&logoColor=white" alt="JWT" />
</p>

<p align="center">
  <a href="https://t.me/O1631C">
    <img src="https://img.shields.io/badge/Telegram-O1631C-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram" />
  </a>
  <a href="https://www.youtube.com/@emir-blockmango1631">
    <img src="https://img.shields.io/badge/YouTube-emir--blockmango1631-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube" />
  </a>
  <a href="https://www.instagram.com/unizhenvvk">
    <img src="https://img.shields.io/badge/Instagram-unizhenvvk-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram" />
  </a>
</p>

---

## О проекте

**SuperNova** - кроссплатформенный мессенджер, разрабатываемый двумя студентами: rimanetcz & ma3rd. Проект задуман как независимое средство общения с собственной серверной частью и оригинальным пользовательским интерфейсом, не повторяющим существующие решения.
  
**Происхождение названия**

Название мессенджера связано с любимым героем rimanetcz в игре Dota 2 - Фениксом. Ультимативная способность этого героя называется Supernova: Феникс обращается в горящую звезду, чтобы после взрыва возродиться вновь. Этот образ - птица, становящаяся звездой и возвращающаяся из огня,  лёг в основу идентичности проекта: от него произошли и имя мессенджера, и феникс как его эмблема, и тёплая огненная палитра интерфейса.

**Команда и распределение ролей**

Проект развивается силами двух человек. rimanetcz отвечает за серверную часть: архитектуру мессенджера, сетевой протокол, авторизацию и обработку сообщений. ma3rd отвечает за клиентскую часть и концепцию интерфейса: структуру компонентов, визуальный стиль, анимации и сценарии использования.
Клиентская часть строится на Flutter - это позволяет поддерживать один и тот же интерфейс на десктопе и мобильных платформах. Интерфейс собран на собственном наборе компонентов, разработанном с нуля без использования стандартных библиотек, что дало проекту узнаваемый визуальный характер.

**Этапы разработки**

Работа над проектом началась с серверной части: rimanetcz собрал первую версию бэкенда и протокол обмена сообщениями. Параллельно ma3rd формировал требования к клиенту: интерфейс мессенджера должен был быть цельным и самобытным, поэтому команда приняла решение отказаться от готовых UI-наборов.
Первая версия клиента представляла собой набор собственных компонентов: кнопки, поля ввода, переключатели, навигацию. Постепенно набор вырос в полноценную библиотеку из более чем сорока виджетов с общей дизайн-системой - палитрой, типографикой и формами компонентов.

Визуальный язык формировался итерациями. Команда последовательно отказывалась от решений, которые выглядели слишком обобщённо, и пришла к стилю, основанному на тёплой палитре и живой анимации: анимированные фоновые сцены с фениксом, горящие индикаторы непрочитанных сообщений, микроанимации элементов управления. Итогом стала тёмная тема с огненными акцентами и полностью кастомным набором компонентов.


В данной ветке находится серверная часть мессенджера была написана на Go + PostgreSQL + WebSocket.

Это рабочая база под реальный чат: авторизация и сессии, личные чаты, группы и каналы, сообщения с вложениями и метаданными, реакции со списком поставивших, пересылка, поиск, закреп, read receipts, упоминания, уведомления в реальном времени, роли, баны, self-муты, модераторские ограничения и ключ темы оформления.

Контракт с фронтом простой: сервер сам собирает готовые объекты (отправитель, вложение, реакции) и кладёт их внутрь ответа.

### Контакты

- Telegram: https://t.me/O1631C
- YouTube: https://www.youtube.com/@emir-blockmango1631
- Instagram: https://www.instagram.com/unizhenvvk

---

## Оглавление

- [О проекте](#о-проекте)
- [Два слоя данных](#два-слоя-данных)
- [Форматы обмена](#форматы-обмена)
- [Response Format](#response-format)
- [Коды ошибок](#коды-ошибок)
- [Пагинация](#пагинация)
- [REST API](#rest-api)
- [Auth](#auth)
- [Users](#users)
- [Blocks](#blocks)
- [Friends](#friends)
- [Chats](#chats)
- [Chat Members](#chat-members)
- [Chat Roles](#chat-roles)
- [Chat Restrictions](#chat-restrictions)
- [Chat Bans](#chat-bans)
- [Chat Mute](#chat-mute)
- [Messages](#messages)
- [Reactions](#reactions)
- [Uploads](#uploads)
- [Notifications](#notifications)
- [Voice](#voice)
- [WebSocket](#websocket)
- [Data Models](#data-models)
- [SQL Schema](#sql-schema)
- [Миграции](#миграции)
- [Структура проекта](#структура-проекта)
- [Локальный запуск](#локальный-запуск)
- [Итог](#итог)

---

## Два слоя данных

В этом документе две разные секции (не путать):

| Секция | Что это | Для кого |
|---|---|---|
| **Data Models** | клиентский контракт, что приходит и уходит по сети в JSON | фронтенд(для подключения бд) |
| **SQL Schema** | реальная схема таблиц PostgreSQL со всеми ключами и ограничениями | бэкенд / БД |

Поэтому в **Data Models** нет `DEFAULT now()`, `INET`, индексов, серверных полей (`password_hash`, хеши токенов) и формальных `UNIQUE/CHECK/PRIMARY KEY` . Семантика, важная фронту (уникальность логина, ключ сущности, обязательность полей, правила валидации), дана **словами**; её формальная реализация живёт в **SQL Schema**.

---

## Форматы обмена

| Место | Формат |
|---|---|
| REST запросы | JSON |
| REST ответы | JSON |
| Загрузки файлов | multipart/form-data (поле `file`) |
| WebSocket | JSON |
| ID | UUID string |
| Время в API | Unix timestamp (seconds) |
| Время в БД | TIMESTAMPTZ |
| Пароли | Argon2id hash |
| Refresh tokens | SHA-256 hash в БД, raw строка по сети |
| Access tokens | JWT |
| IP | INET |
| Notification payload | JSONB |
| Файлы | filesystem `uploads/` |

Авторизация защищённых запросов:

```http
Authorization: Bearer <access_token>
```

JSON-запросы:

```http
Content-Type: application/json
```

Загрузки:

```http
Content-Type: multipart/form-data
```

---

## Response Format

### Успех

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

### Ошибка

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

---

## Коды ошибок

```text
validation_error
unauthorized
forbidden
not_found
conflict
file_too_large
internal_error
```

`forbidden` покрывает в том числе попытку отправить сообщение под модераторским ограничением (`restricted`) и действия, на которые нет прав роли.

---

## Пагинация

Списки возвращаются в обёртке:

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

`limit` задаётся query-параметром `?limit=` (дефолт и максимум зависят от эндпоинта, обычно 20–50 / до 100) дабы не нагружать сервер.

---

## REST API

Base URL:

```text
http://localhost:8080
```

Статика (аватары, баннеры, вложения) отдаётся напрямую:

```text
GET /uploads/avatars/<uuid>.png
GET /uploads/banners/<uuid>.png
GET /uploads/chats/<uuid>.png
GET /uploads/attachments/<uuid>.pdf
```

Файлы неизменяемы по содержимому, поэтому сервер ставит заголовок кеширования:

```http
Cache-Control: public, max-age=3600
```

+ `Last-Modified` / `ETag` от стандартного файл-сервера браузер кеширует и ревалидирует корректно.

---

## Auth

| Method | Path | Описание |
|---|---|---|
| POST | `/auth/register` | Регистрация |
| POST | `/auth/login` | Вход |
| POST | `/auth/logout` | Отзыв refresh-токена |
| POST | `/auth/refresh` | Новая пара токенов |
| GET | `/auth/sessions` | Активные сессии |
| POST | `/auth/sessions/revoke` | Завершить сессию |
| GET | `/health` | Healthcheck |

### POST /auth/register

Запрос:

```json
{
  "email": "alice@example.com",
  "password": "password123",
  "display_name": "Alice",
  "username": "alice"
}
```

Ответ:

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "33333333-3333-7333-8333-333333333333",
      "email": "alice@example.com",
      "username": "alice",
      "display_name": "Alice",
      "bio": null,
      "avatar_url": null,
      "banner_url": null,
      "theme": null,
      "status": "offline",
      "quote": null,
      "music": null,
      "last_seen": null,
      "created_at": 1783150420,
      "updated_at": 1783150420
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "rt_01J8Z...",
    "token_type": "Bearer",
    "expires_in": 900,
    "access_expires_at": 1783151320
  }
}
```

### POST /auth/login

Запрос:

```json
{ "email": "alice@example.com", "password": "password123" }
```

Ответ та же структура, что у регистрации (`user` + пара токенов).

### POST /auth/logout

Запрос (нужен `Authorization`):

```json
{ "refresh_token": "rt_01J8Z..." }
```

Ответ:

```json
{ "success": true, "data": { "revoked": true } }
```

### POST /auth/refresh

Запрос:

```json
{ "refresh_token": "rt_01J8Z..." }
```

Ответ:

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "rt_01J8Z_new...",
    "token_type": "Bearer",
    "expires_in": 900,
    "access_expires_at": 1783151320
  }
}
```

Клиент сам инициирует обновление, когда access-токен протух: HTTP не держит постоянное соединение, сервер не может обновить токен сам. Старый refresh-токен при этом отзывается.

### GET /auth/sessions

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "session-uuid",
        "user_agent": "Mozilla/5.0...",
        "ip": "127.0.0.1",
        "expires_at": 1784841936,
        "created_at": 1784841936
      }
    ],
    "pagination": { "limit": 1, "cursor": null, "has_more": false }
  }
}
```

### POST /auth/sessions/revoke

Запрос:

```json
{ "session_id": "session-uuid" }
```

Ответ:

```json
{ "success": true, "data": { "revoked": true } }
```

### GET /health

```json
{ "success": true, "data": { "status": "ok", "time": 1783150420 } }
```

---

## Users

| Method | Path | Описание |
|---|---|---|
| GET | `/users/me` | Текущий пользователь (с email) |
| PATCH | `/users/me` | Обновить профиль |
| GET | `/users/{userID}` | Профиль пользователя |
| GET | `/users?q=...` | Поиск по username / display_name |

### GET /users/me

```json
{
  "success": true,
  "data": {
    "id": "33333333-3333-7333-8333-333333333333",
    "email": "alice@example.com",
    "username": "alice",
    "display_name": "Alice",
    "bio": "Frontend witch",
    "avatar_url": "/uploads/avatars/33333333-3333-7333-8333-333333333333.png",
    "banner_url": "/uploads/banners/33333333-3333-7333-8333-333333333333.png",
    "theme": "midnight",
    "status": "online",
    "quote": "ship it",
    "music": "Dekma",
    "last_seen": null,
    "created_at": 1783150420,
    "updated_at": 1783150420
  }
}
```

### PATCH /users/me

Запрос (все поля опциональны):

```json
{
  "username": "alice",
  "display_name": "Alice",
  "bio": "hello",
  "theme": "midnight",
  "status": "dnd",
  "quote": "focus mode",
  "music": "The Weeknd"
}
```

`theme` строка-ключ темы (например `dark`, `midnight`). Бэкенд хранит **только это имя** и отдаёт его обратно; сам JSON с палитрой цветов бэкенд **не хранит** клиент по ключу берёт палитру из своего справочника тем. Формат значения бэкенду неизвестен к сожалению, это просто строка (лимит длины 64).

Ответ обновлённый объект пользователя (как в `/users/me`).

### GET /users/{userID}

```json
{
  "success": true,
  "data": {
    "id": "77777777-7777-7777-8777-777777777777",
    "username": "bob",
    "display_name": "Bob",
    "bio": null,
    "avatar_url": null,
    "banner_url": null,
    "theme": null,
    "status": "offline",
    "quote": null,
    "music": null,
    "last_seen": 1783149000,
    "created_at": 1783150420,
    "updated_at": 1783150420
  }
}
```

### GET /users?q=alice

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "33333333-3333-7333-8333-333333333333",
        "username": "alice",
        "display_name": "Alice",
        "avatar_url": null,
        "theme": null,
        "status": "online",
        "last_seen": null,
        "created_at": 1783150420,
        "updated_at": 1783150420
      }
    ],
    "pagination": { "limit": 20, "cursor": null, "has_more": false }
  }
}
```

---

## Blocks

| Method | Path | Описание |
|---|---|---|
| POST | `/block` | Заблокировать |
| POST | `/unblock` | Разблокировать |
| GET | `/blocks` | Список блокировок |

### POST /block

Запрос:

```json
{ "user_id": "77777777-7777-7777-8777-777777777777" }
```

Ответ:

```json
{
  "success": true,
  "data": {
    "blocked_user_id": "77777777-7777-7777-8777-777777777777",
    "created_at": 1783150420
  }
}
```

### POST /unblock

Запрос:

```json
{ "user_id": "77777777-7777-7777-8777-777777777777" }
```

Ответ:

```json
{
  "success": true,
  "data": { "unblocked_user_id": "77777777-7777-7777-8777-777777777777" }
}
```

### GET /blocks

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "blocked_user_id": "77777777-7777-7777-8777-777777777777",
        "username": "bob",
        "display_name": "Bob",
        "avatar_url": null,
        "created_at": 1783150420
      }
    ],
    "pagination": { "limit": 20, "cursor": null, "has_more": false }
  }
}
```

---

## Friends

| Method | Path | Описание |
|---|---|---|
| POST | `/friends/request` | Отправить заявку |
| POST | `/friends/accept` | Принять |
| POST | `/friends/reject` | Отклонить |
| POST | `/friends/remove` | Удалить из друзей |
| GET | `/friends` | Список друзей |
| GET | `/friends/requests?direction=incoming\|outgoing` | Заявки |

Тело `request` / `accept` / `reject` / `remove`:

```json
{ "user_id": "77777777-7777-7777-8777-777777777777" }
```

### POST /friends/request

```json
{
  "success": true,
  "data": {
    "id": "66666666-6666-7666-8666-666666666666",
    "requester_id": "33333333-3333-7333-8333-333333333333",
    "addressee_id": "77777777-7777-7777-8777-777777777777",
    "status": "pending",
    "created_at": 1783150420,
    "updated_at": 1783150420
  }
}
```

### POST /friends/accept

```json
{
  "success": true,
  "data": {
    "id": "66666666-6666-7666-8666-666666666666",
    "requester_id": "77777777-7777-7777-8777-777777777777",
    "addressee_id": "33333333-3333-7333-8333-333333333333",
    "status": "accepted",
    "created_at": 1783150420,
    "updated_at": 1783150500
  }
}
```

### POST /friends/reject

```json
{
  "success": true,
  "data": {
    "id": "66666666-6666-7666-8666-666666666666",
    "requester_id": "77777777-7777-7777-8777-777777777777",
    "addressee_id": "33333333-3333-7333-8333-333333333333",
    "status": "declined",
    "created_at": 1783150420,
    "updated_at": 1783150600
  }
}
```

### POST /friends/remove

```json
{ "success": true, "data": { "removed": true } }
```

### GET /friends

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "66666666-6666-7666-8666-666666666666",
        "user": {
          "id": "77777777-7777-7777-8777-777777777777",
          "username": "bob",
          "display_name": "Bob",
          "avatar_url": null,
          "status": "offline",
          "last_seen": 1783149000
        },
        "status": "accepted",
        "created_at": 1783150420,
        "updated_at": 1783150500
      }
    ],
    "pagination": { "limit": 20, "cursor": null, "has_more": false }
  }
}
```

### GET /friends/requests?direction=incoming

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "66666666-6666-7666-8666-666666666666",
        "user": {
          "id": "77777777-7777-7777-8777-777777777777",
          "username": "bob",
          "display_name": "Bob",
          "avatar_url": null,
          "status": "offline",
          "last_seen": 1783149000
        },
        "status": "pending",
        "created_at": 1783150420,
        "updated_at": 1783150420
      }
    ],
    "pagination": { "limit": 20, "cursor": null, "has_more": false }
  }
}
```

`direction=outgoing` тот же формат, заявки, которые отправил текущий пользователь.

---

## Chats

| Method | Path | Описание |
|---|---|---|
| POST | `/chats` | Создать чат |
| GET | `/chats` | Список чатов |
| GET | `/chats/search?q=...` | Поиск чатов |
| GET | `/chats/{chatID}` | Получить чат |
| PATCH | `/chats/{chatID}` | Обновить инфо |
| DELETE | `/chats/{chatID}` | Удалить чат |
| PATCH | `/chats/{chatID}/settings` | Настройки прав |
| POST | `/chats/{chatID}/pin` | Закрепить чат |
| POST | `/chats/{chatID}/unpin` | Открепить чат |
| POST | `/chats/{chatID}/avatar` | Аватар чата (см. Uploads) |
| POST | `/chats/{chatID}/attachments` | Загрузить вложение (см. Uploads) |
| GET | `/chats/{chatID}/read-status` | Статус прочтения участников |

### POST /chats (private)

Запрос:

```json
{ "type": "private", "member_ids": ["77777777-7777-7777-8777-777777777777"] }
```

Ответ:

```json
{
  "success": true,
  "data": {
    "id": "11111111-1111-7111-8111-111111111111",
    "type": "private",
    "title": null,
    "description": null,
    "avatar_url": null,
    "theme": null,
    "owner_id": null,
    "last_message_id": null,
    "last_message_at": null,
    "allow_member_invite": false,
    "allow_member_edit_info": false,
    "allow_member_send_messages": true,
    "slow_mode_seconds": 0,
    "member_count": 2,
    "is_pinned": false,
    "my_role": "member",
    "unread_count": 0,
    "created_at": 1783150420,
    "updated_at": 1783150420
  }
}
```

### POST /chats (group)

Запрос:

```json
{
  "type": "group",
  "title": "Design Team",
  "description": "Weekly sync",
  "member_ids": ["77777777-7777-7777-8777-777777777777"]
}
```

Ответ:

```json
{
  "success": true,
  "data": {
    "id": "11111111-1111-7111-8111-111111111111",
    "type": "group",
    "title": "Design Team",
    "description": "Weekly sync",
    "avatar_url": null,
    "theme": null,
    "owner_id": "33333333-3333-7333-8333-333333333333",
    "last_message_id": null,
    "last_message_at": null,
    "allow_member_invite": true,
    "allow_member_edit_info": false,
    "allow_member_send_messages": true,
    "slow_mode_seconds": 0,
    "member_count": 2,
    "is_pinned": false,
    "my_role": "owner",
    "unread_count": 0,
    "created_at": 1783150420,
    "updated_at": 1783150420
  }
}
```

### POST /chats (channel)

Запрос:

```json
{ "type": "channel", "title": "News" }
```

> Валидация: у `private` чата `title` всегда `null` (имя берётся из собеседника, см. `GET /chats/{chatID}/companion`); у `group` и `channel` `title` обязателен иначе `400 validation_error`. В БД это же правило выражено как `CHECK (type = 'private' OR title IS NOT NULL)` (см. SQL Schema).

### GET /chats

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "11111111-1111-7111-8111-111111111111",
        "type": "group",
        "title": "Design Team",
        "avatar_url": null,
        "theme": null,
        "last_message_id": "22222222-2222-7222-8222-222222222222",
        "last_message_at": 1783150420,
        "member_count": 5,
        "is_pinned": false,
        "unread_count": 0,
        "created_at": 1783150420,
        "updated_at": 1783150420
      }
    ],
    "pagination": { "limit": 20, "cursor": null, "has_more": false }
  }
}
```

### GET /chats/search?q=design

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "11111111-1111-7111-8111-111111111111",
        "type": "group",
        "title": "Design Team",
        "avatar_url": null,
        "theme": null,
        "member_count": 5,
        "created_at": 1783150420,
        "updated_at": 1783150420
      }
    ],
    "pagination": { "limit": 20, "cursor": null, "has_more": false }
  }
}
```

### PATCH /chats/{chatID}

Запрос:

```json
{ "title": "Product Design", "description": "Discussions", "theme": "ocean" }
```

Ответ обновлённый объект чата.

### PATCH /chats/{chatID}/settings

Запрос:

```json
{
  "allow_member_invite": false,
  "allow_member_edit_info": false,
  "allow_member_send_messages": true,
  "slow_mode_seconds": 10
}
```

Ответ обновлённый объект чата.

### POST /chats/{chatID}/pin и /unpin

```json
{ "success": true, "data": { "chat_id": "11111111-...", "is_pinned": true } }
```

(`is_pinned: false` для `/unpin`.)

### GET /chats/{chatID}/read-status

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "user_id": "33333333-3333-7333-8333-333333333333",
        "username": "alice",
        "display_name": "Alice",
        "avatar_url": null,
        "last_read_message_id": "22222222-2222-7222-8222-222222222222"
      }
    ],
    "pagination": { "limit": 2, "cursor": null, "has_more": false }
  }
}
```

---

## Chat Members

| Method | Path | Описание |
|---|---|---|
| GET | `/chats/{chatID}/members` | Участники |
| GET | `/chats/{chatID}/companion` | Собеседник (private) |
| POST | `/chats/{chatID}/members` | Добавить участника |
| DELETE | `/chats/{chatID}/members/{userID}` | Удалить участника |

### GET /chats/{chatID}/members

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "user_id": "33333333-3333-7333-8333-333333333333",
        "username": "alice",
        "display_name": "Alice",
        "avatar_url": null,
        "status": "online",
        "last_seen": null,
        "role": "owner",
        "is_pinned": false,
        "muted": false,
        "muted_until": null,
        "restricted": false,
        "restricted_until": null,
        "restricted_by": null,
        "restricted_reason": null,
        "joined_at": 1783150420
      }
    ],
    "pagination": { "limit": 1, "cursor": null, "has_more": false }
  }
}
```

`muted` / `restricted` вычисленные флаги «активно ли прямо сейчас». Для ограничения «навсегда» соответствующий `*_until` отдаётся как `null` (фронт видит только `muted: true` / `restricted: true`).

### GET /chats/{chatID}/companion

Возвращает второго участника private-чата (объект пользователя). Для групп и каналов ошибка валидации.

```json
{
  "success": true,
  "data": {
    "id": "77777777-7777-7777-8777-777777777777",
    "username": "bob",
    "display_name": "Bob",
    "avatar_url": null,
    "status": "offline",
    "last_seen": 1783149000
  }
}
```

### POST /chats/{chatID}/members

Запрос:

```json
{ "user_id": "77777777-7777-7777-8777-777777777777", "role": "member" }
```

Ответ:

```json
{
  "success": true,
  "data": {
    "chat_id": "11111111-1111-7111-8111-111111111111",
    "user_id": "77777777-7777-7777-8777-777777777777",
    "added": true
  }
}
```

Забаненного пользователя добавить нельзя (проверка в сервисе + триггер в БД).

### DELETE /chats/{chatID}/members/{userID}

```json
{ "success": true, "data": { "removed": true } }
```

---

## Chat Roles

| Method | Path | Описание |
|---|---|---|
| POST | `/chats/{chatID}/members/{userID}/admin` | Назначить админа |
| DELETE | `/chats/{chatID}/members/{userID}/admin` | Снять админа |
| POST | `/chats/{chatID}/owner/{userID}` | Передать владельца |
| POST | `/chats/{chatID}/members/{userID}/kick` | Кикнуть |

назначать/снимать админа и передавать владельца может только `owner`; кикать `owner` и `admin` (админ не кикает админа); нельзя трогать `owner` и самого себя.

> Почему снятие админа это `DELETE`: путь `.../admin` трактуется как ресурс «флаг админа», и `DELETE` удаляет именно этот флаг, а не участника. Участник остаётся в чате со статусом `member`.

### POST .../admin

```json
{ "success": true, "data": { "chat_id": "11111111-...", "user_id": "77777777-...", "role": "admin" } }
```

### DELETE .../admin

```json
{ "success": true, "data": { "chat_id": "11111111-...", "user_id": "77777777-...", "role": "member" } }
```

### POST .../owner/{userID}

```json
{ "success": true, "data": { "chat_id": "11111111-...", "owner": "77777777-..." } }
```

### POST .../kick

```json
{ "success": true, "data": { "chat_id": "11111111-...", "user_id": "77777777-...", "kicked": true } }
```

---

## Chat Restrictions

Модераторский мут: админ/владелец запрещает участнику писать (временно или навсегда). Это **не** то же самое, что self-mute из раздела Chat Mute (там пользователь сам глушит себе уведомления).

| Method | Path | Описание |
|---|---|---|
| POST | `/chats/{chatID}/members/{userID}/restrict` | Ограничить |
| DELETE | `/chats/{chatID}/members/{userID}/restrict` | Снять ограничение |

### POST .../restrict

Запрос (тело опционально):

```json
{ "duration_seconds": 3600, "reason": "флуд" }
```

`duration_seconds` без значения или `0` = навсегда. Ответ:

```json
{ "success": true, "data": { "chat_id": "11111111-...", "user_id": "77777777-...", "restricted": true } }
```

Ограниченный участник с ролью `member` получает `403 forbidden` при попытке отправить сообщение. `owner`/`admin` ограничение не затрагивает. Админ не может ограничить другого админа. При restrict/unrestrict в чат летит WS-событие `member_restricted` / `member_unrestricted`.

### DELETE .../restrict

```json
{ "success": true, "data": { "chat_id": "11111111-...", "user_id": "77777777-...", "restricted": false } }
```

---

## Chat Bans

| Method | Path | Описание |
|---|---|---|
| POST | `/chats/{chatID}/bans` | Забанить |
| DELETE | `/chats/{chatID}/bans/{userID}` | Разбанить |
| GET | `/chats/{chatID}/bans` | Список банов |

### POST .../bans

Запрос:

```json
{ "user_id": "77777777-7777-7777-8777-777777777777", "reason": "spam" }
```

Ответ:

```json
{ "success": true, "data": { "chat_id": "11111111-...", "user_id": "77777777-...", "banned": true } }
```

Бан удаляет участника из чата и блокирует повторное добавление (триггер в БД).

### DELETE .../bans/{userID}

```json
{ "success": true, "data": { "chat_id": "11111111-...", "user_id": "77777777-...", "banned": false } }
```

### GET .../bans

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "user_id": "77777777-7777-7777-8777-777777777777",
        "username": "bob",
        "display_name": "Bob",
        "avatar_url": null,
        "banned_by": "33333333-3333-7333-8333-333333333333",
        "reason": "spam",
        "created_at": 1783150420
      }
    ],
    "pagination": { "limit": 1, "cursor": null, "has_more": false }
  }
}
```

---

## Chat Mute

Self-mute: пользователь сам глушит себе уведомления чата. Не влияет на других участников.

| Method | Path | Описание |
|---|---|---|
| POST | `/chats/{chatID}/mute` | Замьютить |
| DELETE | `/chats/{chatID}/mute` | Размьютить |
| GET | `/chats/{chatID}/mute` | Статус |

### POST .../mute

Навсегда:

```json
{}
```

На час:

```json
{ "duration_seconds": 3600 }
```

Ответ:

```json
{ "success": true, "data": { "muted": true } }
```

### DELETE .../mute

```json
{ "success": true, "data": { "muted": false } }
```

### GET .../mute

```json
{ "success": true, "data": { "muted": true, "muted_until": 1784845536 } }
```

Для мьюта «навсегда» `muted_until` = `null`.

---

## Messages

| Method | Path | Описание |
|---|---|---|
| GET | `/chats/{chatID}/messages` | Лента |
| GET | `/chats/{chatID}/messages/search?q=...` | Поиск в чате |
| POST | `/chats/{chatID}/messages` | Отправить |
| POST | `/chats/{chatID}/read` | Отметить прочитанным |
| GET | `/chats/{chatID}/pinned` | Закреплённое сообщение |
| POST | `/chats/{chatID}/messages/{messageID}/pin` | Закрепить |
| DELETE | `/chats/{chatID}/messages/{messageID}/pin` | Открепить |
| PATCH | `/messages/{messageID}` | Редактировать |
| DELETE | `/messages/{messageID}` | Удалить |
| POST | `/messages/{messageID}/forward` | Переслать |
| GET | `/messages/{messageID}/read-by` | Кто прочитал |

### Объект сообщения (общий для всех ответов)

```json
{
  "id": "22222222-2222-7222-8222-222222222222",
  "chat_id": "11111111-1111-7111-8111-111111111111",
  "sender": {
    "id": "33333333-3333-7333-8333-333333333333",
    "username": "alice",
    "display_name": "Alice",
    "avatar_url": "/uploads/avatars/33333333-3333-7333-8333-333333333333.png"
  },
  "kind": "text",
  "text": "Hello world",
  "attachment": null,
  "attachment_url": null,
  "reply_to_id": null,
  "forwarded_from_id": null,
  "is_edited": false,
  "is_deleted": false,
  "is_pinned": false,
  "reactions": [
    {
      "emoji": "🔥",
      "count": 2,
      "reacted_by_me": true,
      "users": [
        { "id": "33333333-...", "username": "alice", "display_name": "Alice", "avatar_url": "..." },
        { "id": "44444444-...", "username": "bob", "display_name": "Bob", "avatar_url": null }
      ]
    }
  ],
  "created_at": 1783150420,
  "updated_at": 1783150420,
  "deleted_at": null
}
```

`sender` и `attachment` вложенные объекты, `reactions` со списком поставивших. Фронт **не делает** отдельных запросов за отправителем, за метаданными файла и за участниками реакций всё приходит одним ответом. На сервере это батч-запросы (`WHERE id = ANY(...)`) на страницу, без N+1.

> `sender` содержит только статику профиля (без `status`/`last_seen`): статус меняется каждую минуту, и замазывать его в каждое сообщение = устаревший статус на старых бабблах. Актуальный статус держится в шапке чата и списке участников через WS-событие `presence_changed`.

> `kind` грубая категория (`text` / `image` / `file` / `voice` / `system`). Точный тип вложения фронт берёт из `attachment.mime_type` (`video/mp4`, `application/pdf`, `image/png`, `audio/mpeg`) именно по нему выбирается плеер/превью. Отдельного `kind=video` нет: видео маппится в `file`.

### GET /chats/{chatID}/messages

```json
{
  "success": true,
  "data": {
    "items": [ /* объекты сообщения */ ],
    "pagination": { "limit": 50, "cursor": null, "has_more": false }
  }
}
```

### GET /chats/{chatID}/messages/search?q=hello

Тот же формат списка объектов сообщения.

### POST /chats/{chatID}/messages

Текст:

```json
{ "text": "Hey! shipping today?" }
```

С вложением (по `attachment_id`, полученному от `POST .../attachments`):

```json
{ "text": "spec", "attachment_id": "att-uuid" }
```

Ответ объект сообщения (статус `201`), где `attachment` заполнен:

```json
{
  "success": true,
  "data": {
    "id": "22222222-...",
    "chat_id": "11111111-...",
    "sender": { "id": "33333333-...", "username": "alice", "display_name": "Alice", "avatar_url": "..." },
    "kind": "file",
    "text": "spec",
    "attachment": {
      "id": "att-uuid",
      "url": "/uploads/attachments/99999999-9999-7999-8999-999999999999.pdf",
      "filename": "spec.pdf",
      "mime_type": "application/pdf",
      "size_bytes": 204800,
      "kind": "file",
      "width": null,
      "height": null,
      "created_at": 1783150420
    },
    "attachment_url": "/uploads/attachments/99999999-9999-7999-8999-999999999999.pdf",
    "reply_to_id": null,
    "forwarded_from_id": null,
    "is_edited": false,
    "is_deleted": false,
    "is_pinned": false,
    "reactions": [],
    "created_at": 1783150420,
    "updated_at": 1783150420,
    "deleted_at": null
  }
}
```

### Упоминания

```json
{ "text": "@alice привет" }
```

Если пользователь с таким `username` состоит в чате, он получит уведомление типа `mention` (вместо обычного `message`).

### POST /chats/{chatID}/read

Запрос:

```json
{ "last_message_id": "22222222-2222-7222-8222-222222222222" }
```

Ответ:

```json
{
  "success": true,
  "data": {
    "chat_id": "11111111-...",
    "last_read_message_id": "22222222-2222-7222-8222-222222222222"
  }
}
```

### GET /chats/{chatID}/pinned

Без закрепа:

```json
{ "success": true, "data": { "pinned_message": null } }
```

С закрепом `pinned_message` содержит объект сообщения.

### POST / DELETE .../messages/{messageID}/pin

```json
{ "success": true, "data": { "pinned": true, "message_id": "22222222-..." } }
```

(`pinned: false` для `DELETE`.)

### PATCH /messages/{messageID}

Запрос:

```json
{ "text": "edited text" }
```

Ответ: обновлённый объект сообщения (`is_edited: true`).

### DELETE /messages/{messageID}

Soft-delete: возвращается объект сообщения с `is_deleted: true` и заполненным `deleted_at`.

### POST /messages/{messageID}/forward

Запрос:

```json
{ "chat_id": "target-chat-uuid" }
```

Ответ: созданный объект сообщения в целевом чате (`forwarded_from_id` указывает на оригинал; `sender` = текущий пользователь).

### GET /messages/{messageID}/read-by

```json
{
  "success": true,
  "data": {
    "message_id": "22222222-2222-7222-8222-222222222222",
    "read_by": ["33333333-...", "77777777-..."]
  }
}
```

---

## Reactions

| Method | Path | Описание |
|---|---|---|
| GET | `/messages/{messageID}/reactions` | Реакции со списком поставивших |
| POST | `/messages/{messageID}/reactions` | Поставить |
| DELETE | `/messages/{messageID}/reactions/{emoji}` | Снять |

### POST .../reactions

Запрос:

```json
{ "emoji": "🔥" }
```

Ответ:

```json
{
  "success": true,
  "data": {
    "id": "44444444-4444-7444-8444-444444444444",
    "message_id": "22222222-2222-7222-8222-222222222222",
    "user_id": "33333333-3333-7333-8333-333333333333",
    "emoji": "🔥",
    "created_at": 1783150420
  }
}
```

### GET .../reactions

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "emoji": "🔥",
        "count": 2,
        "reacted_by_me": true,
        "users": [
          { "id": "33333333-...", "username": "alice", "display_name": "Alice", "avatar_url": "..." },
          { "id": "44444444-...", "username": "bob", "display_name": "Bob", "avatar_url": null }
        ]
      }
    ],
    "pagination": { "limit": 1, "cursor": null, "has_more": false }
  }
}
```

### DELETE .../reactions/{emoji}

```json
{ "success": true, "data": { "removed": true } }
```

В WS-событии `reaction_added` приходит полный объект пользователя, поставившего реакцию.

---

## Uploads

| Method | Path | Описание |
|---|---|---|
| POST | `/uploads/avatar` | Аватар пользователя |
| POST | `/uploads/banner` | Баннер пользователя |
| POST | `/chats/{chatID}/avatar` | Аватар чата |
| POST | `/chats/{chatID}/attachments` | Вложение в чат |

Все — `multipart/form-data`, поле `file`.

### POST /uploads/avatar и /uploads/banner

```json
{ "success": true, "data": { "url": "/uploads/avatars/33333333-3333-7333-8333-333333333333.png" } }
```

### POST /chats/{chatID}/avatar

```json
{ "success": true, "data": { "url": "/uploads/chats/11111111-1111-7111-8111-111111111111.png" } }
```

### POST /chats/{chatID}/attachments

Создаёт запись в таблице вложений и возвращает метаданные. Их потом кладут в сообщение через `attachment_id`:

```json
{
  "success": true,
  "data": {
    "id": "att-uuid",
    "url": "/uploads/attachments/99999999-9999-7999-8999-999999999999.pdf",
    "filename": "spec.pdf",
    "mime_type": "application/pdf",
    "size_bytes": 204800,
    "kind": "file"
  }
}
```

---

## Notifications

| Method | Path | Описание |
|---|---|---|
| GET | `/notifications` | Список |
| POST | `/notifications/read` | Прочитать выбранные |
| POST | `/notifications/read-all` | Прочитать все |

Типы: `message`, `mention`, `friend_request`, `friend_accepted`, `chat_invite`, `system`.

Уведомления о новых сообщениях создаются автоматически для участников чата; если участник замьютил чат (self-mute) уведомление не создаётся, что очевидно.

### GET /notifications

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "88888888-8888-7888-8888-888888888888",
        "type": "friend_request",
        "actor_id": "77777777-7777-7777-8777-777777777777",
        "chat_id": null,
        "message_id": null,
        "payload": {},
        "read_at": null,
        "created_at": 1783150420
      }
    ],
    "pagination": { "limit": 20, "cursor": null, "has_more": false }
  }
}
```

### POST /notifications/read

Запрос:

```json
{ "notification_ids": ["88888888-8888-7888-8888-888888888888"] }
```

Ответ:

```json
{ "success": true, "data": { "read_count": 1 } }
```

### POST /notifications/read-all

```json
{ "success": true, "data": { "read_all": true, "read_count": 5 } }
```

---

## Voice

Voice реализован как **stub(заглушка)**: структура и endpoints есть, реального WebRTC пока нет (`join` возвращает `rtc_placeholder_token`), в связи с ограниченными знаниями по данной теме, мы решили временно это не использовать, в будущих обновлениях оно конечно появится, в планах сделать голосовые чаты, схожие с дискордовскими.

| Method | Path | Описание |
|---|---|---|
| POST | `/voice/channels` | Создать канал |
| GET | `/voice/channels/{channelID}` | Получить канал |
| POST | `/voice/channels/{channelID}/join` | Войти |
| POST | `/voice/channels/{channelID}/leave` | Выйти |

### POST /voice/channels

Запрос:

```json
{ "chat_id": "11111111-...", "name": "Lounge", "bitrate": 64000, "max_participants": 25 }
```

Ответ:

```json
{
  "success": true,
  "data": {
    "id": "55555555-5555-7555-8555-555555555555",
    "chat_id": "11111111-...",
    "name": "Lounge",
    "bitrate": 64000,
    "max_participants": 25,
    "participant_count": 0,
    "participants": [],
    "created_at": 1783150420,
    "updated_at": 1783150420
  }
}
```

### GET /voice/channels/{channelID}

```json
{
  "success": true,
  "data": {
    "id": "55555555-...",
    "chat_id": "11111111-...",
    "name": "Lounge",
    "bitrate": 64000,
    "max_participants": 25,
    "participant_count": 1,
    "participants": [
      { "user_id": "33333333-...", "joined_at": 1783150420, "muted": false, "deafened": false }
    ],
    "created_at": 1783150420,
    "updated_at": 1783150420
  }
}
```

### POST .../join

```json
{
  "success": true,
  "data": {
    "channel_id": "55555555-...",
    "joined": true,
    "rtc_token": "rtc_placeholder_token",
    "joined_at": 1783150420
  }
}
```

### POST .../leave

```json
{ "success": true, "data": { "channel_id": "55555555-...", "left": true } }
```

---

## WebSocket

Подключение (access-токен передаётся query-параметром):

```text
GET /ws?token=<access_token>
```

При успешном апгрейде сервер шлёт событие `connected`.

### Формат события

```json
{
  "event": "new_message",
  "chat_id": "11111111-1111-7111-8111-111111111111",
  "data": {},
  "timestamp": 1783150420
}
```

| Поле | Тип |
|---|---|
| `event` | string |
| `chat_id` | uuid / null |
| `data` | object |
| `timestamp` | int64 (unix seconds) |

### Серверные события

```text
connected
new_message
message_updated
message_deleted
reaction_added
reaction_removed
chat_created
chat_updated
chat_deleted
member_added
member_removed
member_restricted
member_unrestricted
typing_start
typing_stop
presence_changed
notification_created
friend_request
friend_accepted
voice_state_updated
messages_read
```

Пример `new_message` (объект сообщения тот же, что в REST, со вложенными `sender`/`attachment`/`reactions`):

```json
{
  "event": "new_message",
  "chat_id": "11111111-...",
  "data": { "message": { "/* объект сообщения */": "..." } },
  "timestamp": 1783150420
}
```

Пример `reaction_added` (с полным пользователем):

```json
{
  "event": "reaction_added",
  "chat_id": "11111111-...",
  "data": {
    "reaction": {
      "id": "44444444-...",
      "message_id": "22222222-...",
      "user": { "id": "33333333-...", "username": "alice", "display_name": "Alice", "avatar_url": "..." },
      "emoji": "🔥",
      "created_at": 1783150420
    }
  },
  "timestamp": 1783150420
}
```

Пример `presence_changed`:

```json
{
  "event": "presence_changed",
  "chat_id": null,
  "data": { "user_id": "33333333-...", "status": "online", "last_seen": null },
  "timestamp": 1783150420
}
```

Пример `messages_read`:

```json
{
  "event": "messages_read",
  "chat_id": "11111111-...",
  "data": { "user_id": "33333333-...", "last_read_message_id": "22222222-..." },
  "timestamp": 1783150420
}
```

### Клиентские события

Клиент отправляет индикатор набора текста; сервер ретранслирует его остальным участникам чата:

```json
{ "event": "typing_start", "chat_id": "11111111-...", "data": {} }
{ "event": "typing_stop",  "chat_id": "11111111-...", "data": {} }
```

---

## Data Models

Клиентский контракт только то, что приходит и уходит по сети. Пометки: `PK` ключ сущности (по нему фронт ключует/дедуплицирует); `NOT NULL` поле всегда есть; `NULLABLE` может отсутствовать. Уникальность и правила валидации даны словами там, где влияют на клиента; их формальная реализация (`CHECK`/`UNIQUE`/индексы) в SQL Schema ниже.

### User

```text
id              uuid        PK
email           string      NOT NULL      уникальный логин; повторная регистрация = 409;
username        string      NULLABLE      уникальный @handle для поиска и mentions; повтор = 409
display_name    string      NOT NULL
bio             string      NULLABLE
avatar_url      string      NULLABLE
banner_url      string      NULLABLE
theme           string      NULLABLE      имя темы (ключ); палитру клиент держит у себя
status          enum        NOT NULL      online | offline | invisible | dnd
quote           string      NULLABLE
music           string      NULLABLE
last_seen       int64       NULLABLE
created_at      int64       NOT NULL
updated_at      int64       NOT NULL
```

### Chat

```text
id                           uuid        PK
type                         enum        NOT NULL      private | group | channel
title                        string      NULLABLE
description                  string      NULLABLE
avatar_url                   string      NULLABLE
theme                        string      NULLABLE      имя темы чата (ключ)
owner_id                     uuid        NULLABLE      null при удалении аккаунта владельца
last_message_id              uuid        NULLABLE
last_message_at              int64       NULLABLE
allow_member_invite          bool        NOT NULL
allow_member_edit_info       bool        NOT NULL
allow_member_send_messages   bool        NOT NULL
slow_mode_seconds            int         NOT NULL
member_count                 int         NOT NULL
is_pinned                    bool        NOT NULL
my_role                      enum        NOT NULL      owner | admin | member  (роль ТЕКУЩЕГО юзера)
unread_count                 int         NOT NULL
created_at                   int64       NOT NULL
updated_at                   int64       NOT NULL

правила:
  private:        title всегда null (имя чата в UI = имя собеседника)
  group/channel:  title обязателен, иначе 400 validation_error

my_role и role в ChatMember  не дубликат. my_role = "моя роль
в этом чате", чтобы фронт без поиска себя в списке участников знал,
может ли он кикать и менять настройки.
```

### Message

```text
id                  uuid        PK
chat_id             uuid        NOT NULL
sender              UserMini    NULLABLE      вложенный объект отправителя
kind                enum        NOT NULL      text | image | file | voice | system
text                string      NULLABLE
attachment          Attachment  NULLABLE      вложенный объект вложения
attachment_url      string      NULLABLE      legacy-дубль url
reply_to_id         uuid        NULLABLE
forwarded_from_id   uuid        NULLABLE
is_edited           bool        NOT NULL
is_deleted          bool        NOT NULL
is_pinned           bool        NOT NULL
reactions           ReactionSummary[]  NOT NULL   агрегат со списком поставивших
created_at          int64       NOT NULL
updated_at          int64       NOT NULL
deleted_at          int64       NULLABLE
```

### UserMini (вложенный)

```text
id            uuid        PK
username      string      NULLABLE
display_name  string      NOT NULL
avatar_url    string      NULLABLE
```

### Attachment (вложенный объект)

```text
id            uuid        PK
url           string      NOT NULL
filename      string      NOT NULL
mime_type     string      NOT NULL
size_bytes    int64       NOT NULL
kind          enum        NOT NULL     image | file | voice
width         int         NULLABLE
height        int         NULLABLE
created_at    int64       NOT NULL
```

### ReactionSummary (агрегат)

Не самостоятельная сущность для запросов, сервер группирует реакции по emoji для ответа.

```text
emoji          string      NOT NULL
count          int         NOT NULL
reacted_by_me  bool        NOT NULL
users          UserMini[]  NOT NULL     все поставившие эту emoji
```

### Reaction (объект в ответе на POST и в WS-событии reaction_added)

```text
id            uuid        PK
message_id    uuid        NOT NULL
user_id       uuid        NOT NULL
emoji         string      NOT NULL
created_at    int64       NOT NULL
```

### Friend

```text
id             uuid        PK
requester_id   uuid        NOT NULL
addressee_id   uuid        NOT NULL
status         enum        NOT NULL     pending | accepted | declined
created_at     int64       NOT NULL
updated_at     int64       NOT NULL

правила: между одной парой одна заявка (повтор = 409); нельзя отправить заявку самому себе.
```

### Block

```text
blocker_id    uuid        NOT NULL
blocked_id    uuid        NOT NULL
created_at    int64       NOT NULL

правила: пара уникальна; нельзя заблокировать самого себя.
```

### ChatMember

```text
chat_id               uuid        NOT NULL
user_id               uuid        NOT NULL
role                  enum        NOT NULL      owner | admin | member
is_pinned             bool        NOT NULL
muted                 bool        NOT NULL      вычисленный флаг (self-mute активен)
muted_until           int64       NULLABLE      self-mute; null = не замьючен
restricted            bool        NOT NULL      вычисленный флаг (модераторский мут активен)
restricted_until      int64       NULLABLE      модераторский мут
restricted_by         uuid        NULLABLE      кто ограничил
restricted_reason     string      NULLABLE
last_read_message_id  uuid        NULLABLE
joined_at             int64       NOT NULL
```

### Notification

```text
id            uuid        PK
user_id       uuid        NOT NULL
type          enum        NOT NULL     message | mention | friend_request | friend_accepted | chat_invite | system
actor_id      uuid        NULLABLE
chat_id       uuid        NULLABLE
message_id    uuid        NULLABLE
payload       json        NOT NULL
read_at       int64       NULLABLE
created_at    int64       NOT NULL
```

### Ban (представление забаненного в списке банов)

```text
user_id       uuid        NOT NULL
username      string      NULLABLE
display_name  string      NOT NULL
avatar_url    string      NULLABLE
banned_by     uuid        NULLABLE
reason        string      NULLABLE
created_at    int64       NOT NULL
```

---

## SQL Schema

Финальная схема таблиц (состояние БД после применения всех миграций). Для установки с нуля можно применить миграции по порядку (см. следующий раздел) либо создать таблицы сразу по этому снимку, порядок здесь валиден для выполнения с нуля.

<details>
<summary>Итоговая схема (click to expand)</summary>

```sql
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

-- Триггер: нельзя добавить в чат забаненного
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
```

</details>

---

## Миграции

Файлы в `internal/db/migrations/` применяются по порядку:

| Файл | Что делает |
|---|---|
| `0001_init.sql` | Базовая схема: users, blocks, friends, chats, chat_members, messages, reactions, voice, notifications, refresh_tokens + индексы |
| `0002_pinned_message.sql` | `chats.pinned_message_id` |
| `0003_chat_mutes.sql` | *(ничего не делает, просто висит)* создавала отдельную таблицу `chat_mutes` |
| `0004_chat_bans.sql` | таблица `chat_bans` |
| `0005_ban_trigger.sql` | триггер запрета добавления забаненного |
| `0006_mute_collapse.sql` | схлопывает self-мут в `chat_members.muted_until`, удаляет `chat_mutes` и мёртвую колонку `muted` |
| `0007_attachments.sql` | таблица `attachments` + `messages.attachment_id` |
| `0008_chat_restrictions.sql` | `chat_members.restricted_until/_by/_reason` |
| `0009_theme.sql` | убирает `accent_color` (users, chats), добавляет `theme TEXT` |



Применение:

```bash
docker exec -i supernova-postgres psql -U supernova -d supernova < internal/db/migrations/0001_init.sql
docker exec -i supernova-postgres psql -U supernova -d supernova < internal/db/migrations/0002_pinned_message.sql
docker exec -i supernova-postgres psql -U supernova -d supernova < internal/db/migrations/0003_chat_mutes.sql
docker exec -i supernova-postgres psql -U supernova -d supernova < internal/db/migrations/0004_chat_bans.sql
docker exec -i supernova-postgres psql -U supernova -d supernova < internal/db/migrations/0005_ban_trigger.sql
docker exec -i supernova-postgres psql -U supernova -d supernova < internal/db/migrations/0006_mute_collapse.sql
docker exec -i supernova-postgres psql -U supernova -d supernova < internal/db/migrations/0007_attachments.sql
docker exec -i supernova-postgres psql -U supernova -d supernova < internal/db/migrations/0008_chat_restrictions.sql
docker exec -i supernova-postgres psql -U supernova -d supernova < internal/db/migrations/0009_theme.sql
```

Запросы к БД параметризованы через `pgx` (`$1`, `$2`, ...), без склейки строк.

---

## Структура проекта

```text
supernova/
├── cmd/server/main.go          точка входа: сборка зависимостей и запуск HTTP
├── internal/
│   ├── config/                 чтение .env и конфигурации
│   ├── domain/                 чистые модели без зависимостей
│   ├── db/                     подключение к БД + migrations/
│   ├── repository/             только SQL / работа с PostgreSQL
│   ├── service/                бизнес-логика, правила, проверки прав
│   ├── api/
│   │   ├── router.go           маршруты
│   │   ├── middleware/         auth, recover, request_id, ratelimit
│   │   ├── dto/                структуры запросов/ответов (контракт)
│   │   ├── handlers/           HTTP-обработчики (парсинг, ответы)
│   │   └── response/           единый формат ответа {success,data,error,meta}
│   ├── ws/                     WebSocket: hub / client / events / handler
│   └── pkg/                    переиспользуемые утилиты
│       ├── unixtime/           сериализация времени в unix-seconds
│       ├── hasher/             Argon2id
│       ├── jwt/                выдача/проверка JWT
│       ├── validator/          валидация ввода
│       └── storage/            сохранение файлов на диск
├── uploads/                    avatars / banners / chats / attachments
├── .env
├── go.mod
└── go.sum
```

Правило архитектуры: запрос идёт **handlers → service → repository**. SQL не лезет в HTTP, бизнес-логика не знает про `pgx`, модели не зависят ни от кого. Это позволяет менять хранилище или транспорт, не переписывая остальное.

---

## Локальный запуск

```bash
docker compose up -d                 # поднять PostgreSQL
go run cmd/server/main.go            # запустить сервер 
```

---

## Итог

Что умеет бэкенд:

```text
auth + sessions + refresh
users + profile + поиск
uploads (аватары, баннеры, вложения с метаданными)
blocks
friends
chats (private / group / channel)
chat members + companion
roles (admin / owner / kick)
restrictions (модераторский мут)
bans (+ триггер запрета добавления)
self-mute
theme (ключ темы оформления)
messages (send / edit / delete / forward / search / pin / read-by)
вложенные sender и attachment в сообщениях (батчем, без N+1)
reactions со списком поставивших
mentions (@username)
notifications + realtime через WebSocket
presence (online / offline)
voice (stub)
```

