#Supernova Messenger Backend

Полноценный бэкенд для мессенджера на **Go + Gin + PostgreSQL + WebSocket**.

##Возможности

---

###Пользователи
- Регистрация и авторизация (JWT токены)
- Профили с аватарками, био и статусами
- Поиск пользователей по username
- Блокировка пользователей

---

###Чаты
- Личные сообщения 
- Групповые чаты с участниками
- Создание групп без предварительного добавления участников
- Добавление участников по username
- Удаление участников из чата
- Выход из чата
- Переименование чатов
- Передача прав владельца

---

###Сообщения
- Текстовые сообщения
- Отправка фото/файлов
- Ответы на сообщения (Reply)
- Пересылка сообщений (Forward)
- Редактирование сообщений
- Мягкое удаление сообщений
- Закрепление сообщений в чате
- Поиск по сообщениям (серверный)
- Статусы доставки и прочтения (✓, ✓✓, синие ✓✓)

---

###Уведомления и статусы
- Индикатор "печатает..."
- Статусы онлайн/оффлайн в реальном времени
- "Был(а) в сети ..."
- Мьют чата (отключение уведомлений)
- Счетчики непрочитанных сообщений

---

###Голосовые каналы (WebRTC) (не реализовано ибо фронтед отстает)
- Вход/выход из голосового канала
- Обмен SDP offer/answer
- Обмен ICE candidates
- Mute/unmute микрофона
- Индикация кто говорит

---

###Real-time 
- Мгновенная доставка сообщений
- Синхронизация при переподключении
- События онлайн/оффлайн
- Typing indicators
- Обновления статусов прочтения

---

##Технологии

- **Go 1.22** — основной язык
- **Gin** — HTTP фреймворк
- **GORM** — ORM для PostgreSQL
- **PostgreSQL 16** — база данных
- **WebSocket** — real-time коммуникация
- **JWT** — авторизация
- **Bcrypt** — хеширование паролей

---

##Структура проекта

supernova/
├── cmd/
 |           └── server/
 |                          └──  main.go  
 |                              
├── internal/  
 |               └──  config/      
 |                |              └── config.go
 |                | 
 |               └──  database/
 |                |                 └── db.go
 |                | 
 |               ├── handlers/
 |                |               ├──auth.go
 |                |               ├── chat_members.go         
 |                |               ├── chat_pin.go             
 |                |               ├── chat_rename.go    
 |                |               ├── chat_search.go
 |                |               ├── chat_settings.go        
 |                |               ├── chat_sync.go             
 |                |               ├── chats.go
 |                |               ├── chats_create.go
 |                |               ├── message_action.go       
 |                |               ├── message_response.go            
 |                |               ├── messages.go
 |                |               ├── upload.go
 |                |               ├── user_blocks.go
 |                |               ├── user_status.go
 |                |               ├── users.go
 |                |               └── websocket.go
 |               ├── hub/
 |                |          └── hub.go
 |                |
 |               ├── middleware/
 |                |                     └── auth.go
 |                |
 |               └── models/
 |                                └── models.go
├── uploads/    
 |                └── картинки и все что грузят юзеры.png  
 |
├── тестовый хтмл.html              
├── go.mod        
├── go.sum
├── messenger.db
└── .env

---

##API ENDPOINTS
POST - /api/register - Регистрация нового пользователя
POST - /api/login - Вход в систему


Пример запроса (register):|
{
  "username": "testuser",
  "password": "123456",
  "phone": "+79991234567"
}

Пример ответа: 
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "username": "testuser",
    "avatar_url": null,
    "bio": null,
    "created_at": "2026-07-07T10:00:00Z"
  }
}

---

Пользователи:

GET /api/users/me  Получить свой профиль
PUT /api/users/me  Обновить профиль
GET /api/users/search?query=...  Поиск пользователей
GET /api/users/:user_id  Получить профиль пользователя
GET /api/users/:user_id/status  Получить статус пользователя
POST /api/users/me/status  Обновить свой статус (last_seen)
POST /api/users/:user_id/block  Заблокировать пользователя
DELETE /api/users/:user_id/block  Разблокировать пользователя


Пример обновления профиля: 
{
  "display_name": "Иван Иванов",
  "bio": "Привет, я использую Supernova!",
  "avatar_url": "https://example.com/avatar.jpg"
}

---

Чаты:

GET /api/chats  Список чатов пользователя
POST /api/chats  Создать групповой чат
POST /api/chats/private  Создать личный чат
GET /api/chats/:chat_id/messages  Получить сообщения чата
GET /api/chats/:chat_id/sync  Синхронизация сообщений
GET /api/chats/:chat_id/messages/search  Поиск по сообщениям
GET /api/chats/:chat_id/members  Участники чата
POST /api/chats/:chat_id/members  Добавить участника
POST /api/chats/:chat_id/add_by_username  Добавить по username
DELETE /api/chats/:chat_id/members/:user_id  Удалить участника
POST /api/chats/:chat_id/leave  Выйти из чата
POST /api/chats/:chat_id/read  Отметить как прочитанное
POST /api/chats/:chat_id/typing  Индикатор "печатает"
POST /api/chats/:chat_id/mute  Мьют чата
POST /api/chats/:chat_id/transfer  Передать права владельца
PUT /api/chats/:chat_id  Переименовать чат
POST /api/chats/:chat_id/pin/:message_id  Закрепить сообщение
DELETE /api/chats/:chat_id/pin  Открепить сообщение
GET /api/chats/:chat_id/pinned  Получить закреплённое сообщение


Пример создания личного чата: 
{
  "username": "bananchik"
}


Пример создания группы:
{
  "name": "Моя группа",
  "type": "group",
  "user_ids": []
}

---

Сообщения: 
POST /api/messages  Отправить сообщение
PUT /api/messages/:message_id  Редактировать сообщение
DELETE /api/messages/:message_id  Удалить сообщение
POST /api/messages/:message_id/forward  Переслать сообщение


Пример отправки сообщения: 
{
  "chat_id": "uuid",
  "text": "Привет!",
  "type": "text",
  "reply_to": "uuid_сообщения"
}


Пример ответа: 
{
  "message": {
    "id": "uuid",
    "chat_id": "uuid",
    "from_user": {
      "id": "uuid",
      "username": "testuser",
      "avatar_url": null
    },
    "content": [
      {
        "type": "text",
        "value": "Привет!"
      }
    ],
    "status": "sent",
    "created_at": "2026-07-07T10:00:00Z"
  }
}


---

Загрузка файлов:
POST /api/upload  Загрузить файл


Пример загрузки:
file: [binary]

Пример ответа:
{
  "file_url": "/uploads/uuid.jpg"
}

---

WebSocket Подключение:
GET /api/ws?token=JWT_TOKEN

---

События от клиента:
subscribe { chat_id: "uuid" }  Подписка на чат
typing { chat_id, user_id, username }  Пользователь печатает
stop_typing { chat_id, user_id }  Перестал печатать
read_receipt { chat_id, message_ids, user_id }  Прочитал сообщения
voice_join { chat_id }  Войти в голосовой канал
voice_leave {}  Выйти из голосового канала
voice_sdp { target_user_id, sdp, type }  Обмен SDP
voice_ice { target_user_id, candidate }  Обмен ICE
voice_mute { is_muted }  Mute/unmute

---

События от сервера:
new_message Новое сообщение
message_edited Сообщение отредактировано
message_deleted Сообщение удалено
typing Пользователь печатает
stop_typing Перестал печатать
messages_read Сообщения прочитаны
online_status Статус онлайн/оффлайн
message_pinned Сообщение закреплено
message_unpinned Сообщение откреплено
chat_renamed Чат переименован
chat_muted Чат замьючен
chat_transferred Права переданы
voice_channel_info Информация о канале
voice_user_joined Пользователь вошёл в канал
voice_user_left Пользователь вышел из канала
voice_new_peer Новый участник канала
voice_sdp SDP offer/answer
voice_ice ICE candidate
voice_user_muted Пользователь замьючен

---

##База данных(таблицы)
users — пользователи
chats — чаты (личные и групповые)
chat_members — участники чатов
messages — сообщения
message_status — статусы сообщений
blocks — блокировки пользователей
voice_channels — голосовые каналы
voice_participants — участники голосовых каналов

---

##.env
APP_PORT Порт сервера  8080
DB_HOST Хост базы данных  localhost
DB_PORT Порт PostgreSQL  5432
DB_USER Пользователь БД  postgres
DB_PASSWORD Пароль БД  postgres
DB_NAME Название БД  messenger_db
JWT_SECRET Секретный ключ JWT  (обязательно)
JWT_EXPIRY_HOURS Время жизни токена (часы)  720
UPLOAD_DIR Папка для загрузок  ./uploads
LOG_LEVEL Уровень логирования  info
