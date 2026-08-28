import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

part 'db_service.g.dart';

@DataClassName('User')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get username => text().unique().nullable()();
  TextColumn get displayName => text()();
  TextColumn get bio => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get bannerUrl => text().nullable()();
  TextColumn get theme => text().nullable()();
  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK(status IN ('online', 'offline', 'invisible', 'dnd'))",
  )();
  TextColumn get quote => text().nullable()();
  TextColumn get music => text().nullable()();
  DateTimeColumn get lastSeen => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Chat')
class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().customConstraint(
    "NOT NULL CHECK(type IN ('private','group','channel'))",
  )();
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get theme => text().nullable()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get lastMessageId => text().nullable()();
  IntColumn get lastMessageAt => integer().nullable()();
  BoolColumn get allowMemberInvite =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get allowMemberEditInfo =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get allowMemberSendMessages =>
      boolean().withDefault(const Constant(true))();
  IntColumn get slowModeSeconds => integer().withDefault(const Constant(0))();
  IntColumn get memberCount => integer().withDefault(const Constant(1))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get myRole => text().customConstraint(
    "NOT NULL CHECK(my_role IN ('owner', 'admin', 'member'))",
  )();
  TextColumn get pinnedMessageId => text().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Message')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get sender => text().map(const UserMiniConverter()).nullable()();
  TextColumn get kind => text().customConstraint(
    "NOT NULL CHECK(kind IN ('text','image','voice','file','system'))",
  )();
  TextColumn get messageText => text().nullable()();
  TextColumn get attachment =>
      text().map(const AttachmentConverter()).nullable()();
  TextColumn get attachmentUrl => text().nullable()();
  TextColumn get replyToId => text().nullable()();
  TextColumn get forwardedFromId => text().nullable()();
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  TextColumn get reactions => text()
      .map(const ReactionSummaryConverter())
      .withDefault(const Constant('[]'))();

  // TODO TextColumn get reactions => text().map(const ReactionsSummary).withDefault(const Constant("[]"))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserMini {
  final String id;
  final String? username;
  String displayName;
  String? avatarUrl;

  UserMini({
    required this.id,
    this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory UserMini.fromJson(Map<String, dynamic> json) {
    return UserMini(
      id: json['id'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName,
    'avatar_url': avatarUrl,
  };
}

class UserMiniConverter extends TypeConverter<UserMini, String> {
  const UserMiniConverter();

  @override
  UserMini fromSql(String fromDb) => UserMini.fromJson(jsonDecode(fromDb));

  @override
  String toSql(UserMini data) => jsonEncode(data.toJson());
}

class Attachment {
  final String id;
  final String url;
  final String filename;
  final String mimeType;
  final String sizeBytes;
  final String kind;
  final int? width;
  final int? height;
  final int createdAt;

  Attachment({
    required this.id,
    required this.url,
    required this.filename,
    required this.mimeType,
    required this.sizeBytes,
    required this.kind,
    this.width,
    this.height,
    required this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      url: json['url'] as String,
      filename: json['filename'] as String,
      mimeType: json['mime_type'] as String,
      sizeBytes: json['size_bytes'] as String,
      kind: json['kind'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      createdAt: json['created_at'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'filename': filename,
    'mime_type': mimeType,
    'size_bytes': sizeBytes,
    'kind': kind,
    'width': width,
    'height': height,
    'created_at': createdAt,
  };
}

class AttachmentConverter extends TypeConverter<Attachment, String> {
  const AttachmentConverter();

  @override
  Attachment fromSql(String fromDb) => Attachment.fromJson(jsonDecode(fromDb));

  @override
  String toSql(Attachment data) => jsonEncode(data.toJson());
}

class ReactionSummary {
  final String emoji;
  final int count;
  final bool reactedByMe;
  final List<UserMini> users;

  ReactionSummary({
    required this.emoji,
    required this.count,
    required this.reactedByMe,
    required this.users,
  });

  factory ReactionSummary.fromJson(Map<String, dynamic> json) {
    return ReactionSummary(
      emoji: json['emoji'] as String,
      count: json['count'] as int,
      reactedByMe: json['reacted_by_me'] as bool,
      users: (json['users'] as List<dynamic>)
          .map((e) => UserMini.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'count': count,
    'reacted_by_me': reactedByMe,
    'users': users.map((u) => u.toJson()).toList(),
  };
}

class ReactionSummaryConverter extends TypeConverter<ReactionSummary, String> {
  const ReactionSummaryConverter();

  @override
  ReactionSummary fromSql(String fromDb) =>
      ReactionSummary.fromJson(jsonDecode(fromDb));

  @override
  String toSql(ReactionSummary data) => jsonEncode(data.toJson());
}
// @DataClassName('Attachment')
// class Attachments extends Table {
//   TextColumn get id => text()();
//   TextColumn get url => text()();
//   TextColumn get filename => text()();
//   TextColumn get mimeType => text()();
//   IntColumn get sizeBytes => integer()();
//   TextColumn get kind => text().customConstraint("NOT NULL CHECK(kind IN ())")();
//   IntColumn get messageId => integer()();
//   TextColumn get fileName => text().nullable()();
//   TextColumn get filePath => text().nullable()();
//   DateTimeColumn get uploadedAt => dateTime().withDefault(currentDateAndTime)();

//   @override
//   Set<Column> get primaryKey => {id};
// }

@DataClassName('MessageReaction')
class MessageReactions extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text()();
  TextColumn get userId => text()();
  TextColumn get emoji => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {messageId, userId, emoji},
  ];

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Friend')
class Friends extends Table {
  TextColumn get id => text()();
  TextColumn get requesterId => text()();
  TextColumn get addresseeId => text()();
  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK(status IN ('pending', 'accepted', 'declined'))",
  )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => ['CHECK(requester_id <> addressee_id)'];

  @override
  Set<Column> get primaryKey => {requesterId, addresseeId};
}

@DataClassName('MessageState')
class MessageStates extends Table {
  IntColumn get messageId => integer()();
  TextColumn get userId => text()();

  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK(status IN ('sent', 'read', 'delivered'))",
  )();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {messageId, userId};
}

@DataClassName('Block')
class Blocks extends Table {
  TextColumn get blockerId => text()();
  TextColumn get blockedId => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {blockerId, blockedId};

  @override
  List<String> get customConstraints => ['CHECK(blocker_id <> blocked_id)'];
}

@DataClassName('ChatMember')
class ChatMembers extends Table {
  TextColumn get chatId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text().customConstraint(
    "NOT NULL CHECK(role IN ('owner','admin','member'))",
  )();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get muted => boolean().withDefault(const Constant(false))();
  TextColumn get lastReadMessageId => text().nullable()();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {chatId, userId};
}

@DataClassName('ChatMute')
class ChatMutes extends Table {
  TextColumn get chatId => text()();
  TextColumn get userId => text()();
  IntColumn get mutedUntil => integer()
      .nullable()(); // зачем нужна отдельная таблица если можно просто хранить значение mutedUntil
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // TextColumn muterId -> айди того кто замутил??

  @override
  Set<Column> get primaryKey => {chatId, userId};
}

@DataClassName('ChatBan')
class ChatBans extends Table {
  TextColumn get chatId => text()();
  TextColumn get userId => text()();
  TextColumn get bannedBy => text().nullable()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {chatId, userId};
}

@DataClassName('Notification')
class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text().customConstraint(
    "NOT NULL CHECK(type IN ('message', 'mention', 'friend_request', 'friend_accepted', 'chat_invite', 'system'))",
  )();
  TextColumn get actorId => text().nullable()();
  TextColumn get chatId => text().nullable()();
  TextColumn get messageId => text().nullable()();
  TextColumn get payload => text()(); // json
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RefreshToken') // я так понимаю это не нужно в клиенте
class RefreshTokens extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get tokenHash => text()();
  TextColumn get userAgent => text().nullable()();
  TextColumn get ip => text().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get revokedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  MyDatabase? _db;
  bool _isInit = false;

  void checkInit() {
    if (!_isInit || _db == null) {
      throw SqliteException(
        extendedResultCode: 1,
        message: "Database isn't initialized",
      );
    }
  }

  Future<void> openDB(String name) async {
    await _db?.close();

    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'supernova_client', 'db', name));

    _db = MyDatabase(file);
    _isInit = true;
  }

  Stream<List<Message>> watchAllMessages(String currentChatId) {
    checkInit();
    return _db!.watchAllMessages(currentChatId);
  }

  Stream<List<(Chat, Message?)>> watchAllChats() {
    checkInit();
    return _db!.watchAllChats();
  }

  Future<List<Message>> getChatHistory(String currentChatId) {
    checkInit();
    return _db!.getChatHistory(currentChatId);
  }

  Future<List<Map<String, dynamic>>> getMessages(String chatId) {
    checkInit();
    return _db!.getMessages(chatId);
  }

  Future<int> sendMessage(Message message) {
    checkInit();
    _db!.updateChat(message.chatId);
    return _db!.addMessage(message);
  }

  Future<int> updateMessage(Message message) {
    checkInit();
    return _db!.updateMessage(message);
  }

  Future<Chat?> getChat(String chatId) {
    checkInit();
    return _db!.getChat(chatId);
  }

  Future<String> createChat({required Chat chat}) async {
    checkInit();
    try {
      await _db!.createChat(chat);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<User?> getUser(String userId) {
    checkInit();
    return _db!.getUser(userId);
  }

  Future<void> batchChats(List<Chat> data) {
    checkInit();
    return _db!.batchChats(data);
  }

  Future<void> batchChat(String chatId, List<Message> data) {
    checkInit();
    return _db!.batchChat(chatId, data);
  }
}

@DriftDatabase(
  tables: [
    Users,
    Chats,
    ChatMembers,
    Messages,
    MessageReactions,
    MessageStates,
  ],
)
class MyDatabase extends _$MyDatabase {
  MyDatabase(File file) : super(_openConnection(file));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll(); // 👈 АЛО!
      },
      onUpgrade: (m, from, to) async {
        print('🔄 Обновление с $from до $to');
      },
    );
  }

  static LazyDatabase _openConnection(File file) {
    return LazyDatabase(() async {
      // final dbFolder = Platform.isWindows || Platform.isLinux || Platform.isMacOS
      //   ? Directory.current.path
      //   : (await getApplicationDocumentsDirectory()).path;
      // final file = File(p.join(dbFolder, '\\assets\\', name));

      return NativeDatabase.createInBackground(file);
    });
  }

  Future<int> addMessage(Message message) async {
    return into(messages).insert(message);
  }

  Future<int> updateMessage(Message message) async {
    return (update(
      messages,
    )..where((msg) => msg.id.equals(message.id))).write(message);
  }

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    return await (select(messages)
          ..where((msg) => msg.chatId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get()
        .then((list) => list.map((m) => m.toJson()).toList());
  }

  Stream<List<Message>> watchAllMessages(String currentChatId) {
    return (select(messages)
          ..where((msg) => msg.chatId.equals(currentChatId))
          ..orderBy([(msg) => OrderingTerm.asc(msg.createdAt)]))
        .watch();
  }

  Stream<List<(Chat, Message?)>> watchAllChats() {
    final query = select(chats)
      ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]);

    return query.watch().asyncMap((chatList) async {
      final result = <(Chat, Message?)>[];

      for (final chat in chatList) {
        final lastMessage =
            await (select(messages)
                  ..where((m) => m.chatId.equals(chat.id))
                  ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
                  ..limit(1))
                .getSingleOrNull();

        result.add((chat, lastMessage));
      }
      return result;
    });
  }

  Stream<List<(Chat, Message?)>> watchAllChatsV2() {
    final chatStream = select(chats).watch();
    final messagesStream = select(messages).watch();

    return Rx.combineLatest2(chatStream, messagesStream, (
      List<Chat> chatList,
      List<Message> messagesList,
    ) {
      return chatList.map((chat) {
        final chatMessages = messagesList
            .where((m) => m.chatId == chat.id)
            .toList();

        chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final lastMessage = chatMessages.isEmpty ? null : chatMessages.first;

        return (chat, lastMessage);
      }).toList();
    });
  }

  Future<List<Message>> getChatHistory(String currentChatId) {
    return (select(messages)
          ..where((msg) => msg.chatId.equals(currentChatId))
          ..orderBy([(msg) => OrderingTerm.asc(msg.createdAt)]))
        .get();
  }

  Future<Chat?> getChat(String chatId) {
    return (select(
      chats,
    )..where((chat) => chat.id.equals(chatId))).getSingleOrNull();
  }

  Future<User?> getUser(String userId) {
    return (select(
      users,
    )..where((user) => user.id.equals(userId))).getSingleOrNull();
  }

  Future<void> createChat(Chat chat) {
    return into(chats).insert(chat);
  }

  Future<void> updateChat(String chatId) {
    return (update(chats)..where((chat) => chat.id.equals(chatId))).write(
      ChatsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> batchChats(List<Chat> data) async {
    await transaction(() async {
      await delete(chats).go();

      await batch((batch) {
        batch.insertAll(chats, data);
      });
    });
  }

  Future<void> batchChat(String chatId, List<Message> data) async {
    await transaction(() async {
      // await (delete(messages)
      //     ..where((tbl) => tbl.chatId.equals(chatId)))
      //   .go();

      await batch((batch) {
        batch.insertAllOnConflictUpdate(messages, data);
      });
    });
  }
}

Message messagefromMap(Map<dynamic, dynamic> data) {
  return Message(
    id: data['id'],
    chatId: data['chat_id'],
    sender: data['sender'] != null ? UserMini.fromJson(data['sender']) : null,
    kind: data['kind'],
    messageText: data['text'],
    attachment: data['attachment'] != null
        ? Attachment.fromJson(data['attachment'])
        : null,
    attachmentUrl: data['attachment_url'],
    replyToId: data['reply_to_id'],
    forwardedFromId: data['forwarded_from_id'],
    isEdited: data['is_edited'] ?? false,
    isDeleted: data['is_deleted'] ?? false,
    isPinned: data['is_pinned'] ?? false,
    reactions: data['reactions'] != null
        ? data['reactions'] is Map
              ? ReactionSummary.fromJson(data['reactions'])
              : ReactionSummary(
                  emoji: '',
                  count: 0,
                  reactedByMe: false,
                  users: [],
                )
        : ReactionSummary(emoji: '', count: 0, reactedByMe: false, users: []),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (data['created_at'] as int) * 1000,
    ),
    updatedAt: data['updated_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (data['updated_at'] as int) * 1000,
          )
        : null,
    deletedAt: data['deleted_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            (data['deleted_at'] as int) * 1000,
          )
        : null,
  );
}

Map<String, dynamic>? messageToMap({
  Message? message,
  MessagesCompanion? companion,
}) {
  if (message != null) {
    return {
      'id': message.id,
      'chat_id': message.chatId,
      'sender': message.sender?.toJson(),
      'kind': message.kind,
      'text': message.messageText,
      'attachment': message.attachment?.toJson(),
      'attachment_url': message.attachmentUrl,
      'reply_to_id': message.replyToId,
      'forwarded_from_id': message.forwardedFromId,
      'is_edited': message.isEdited,
      'is_deleted': message.isDeleted,
      'is_pinned': message.isPinned,
      'reactions': message.reactions.toJson(),
      'created_at': message.createdAt.millisecondsSinceEpoch,
      'updated_at': message.updatedAt?.millisecondsSinceEpoch,
      'deleted_at': message.deletedAt?.millisecondsSinceEpoch,
    };
  }
  if (companion != null) {
    return {
      'id': companion.id.present ? companion.id.value : null,
      'chat_id': companion.chatId.present ? companion.chatId.value : null,
      'sender': companion.sender.present
          ? companion.sender.value?.toJson()
          : null,
      'kind': companion.kind.present ? companion.kind.value : null,
      'text': companion.messageText.present
          ? companion.messageText.value
          : null,
      'attachment': companion.attachment.present
          ? companion.attachment.value?.toJson()
          : null,
      'attachment_url': companion.attachmentUrl.present
          ? companion.attachmentUrl.value
          : null,
      'reply_to_id': companion.replyToId.present
          ? companion.replyToId.value
          : null,
      'forwarded_from_id': companion.forwardedFromId.present
          ? companion.forwardedFromId.value
          : null,
      'is_edited': companion.isEdited.present ? companion.isEdited.value : null,
      'is_deleted': companion.isDeleted.present
          ? companion.isDeleted.value
          : null,
      'is_pinned': companion.isPinned.present ? companion.isPinned.value : null,
      'reactions': companion.reactions.present
          ? companion.reactions.value.toJson()
          : null,
      'created_at': companion.createdAt.present
          ? companion.createdAt.value.millisecondsSinceEpoch
          : null,
      'updated_at': companion.updatedAt.present
          ? companion.updatedAt.value?.millisecondsSinceEpoch
          : null,
      'deleted_at': companion.deletedAt.present
          ? companion.deletedAt.value?.millisecondsSinceEpoch
          : null,
    };
  }
  return null;
}

Chat chatFromMap(Map<dynamic, dynamic> data) {
  return Chat(
    id: data['id'],
    type: data['type'],
    title: data['title'],
    description: data['description'],
    avatarUrl: data['avatar_url'],
    theme: data['theme'],
    ownerId: data['owner_id'],
    lastMessageId: data['last_message_id'],
    lastMessageAt: data['last_message_at'],
    allowMemberInvite: data['allow_member_invite'] ?? true,
    allowMemberEditInfo: data['allow_member_edit_info'] ?? true,
    allowMemberSendMessages: data['allow_member_send_messages'] ?? true,
    slowModeSeconds: data['slow_mode_seconds'] ?? 0,
    memberCount: data['member_count'] ?? 1,
    isPinned: data['is_pinned'] ?? false,
    myRole: data['my_role'] ?? 'member',
    unreadCount: data['unread_count'] ?? 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(data['created_at'] * 1000),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updated_at'] * 1000),
  );
}

/*
Chat(
              id: chat['id'],
              type: chat['type'],
              title: chat['title'],
              description: chat['description'],
              avatarUrl: chat['avatar_url'],
              ownerId: chat['owner_id'],
              lastMessageId: chat['last_message_id'],
              lastMessageAt: chat['last_message_at'],
              allowMemberInvite: chat['allow_member_invite'],
              allowMemberEditInfo: chat['allow_member_edit_info'],
              allowMemberSendMessages: chat['allow_member_send_messages'],
              slowModeSeconds: chat['slow_mode_seconds'],
              memberCount: chat['members_count'],
              isPinned: chat['is_pinned'],
              myRole: chat['my_role'],
              unreadCount: chat['unread_count'],
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                chat['created_at'] * 1000,
              ),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                chat['updated_at'] * 1000,
              ),
            );
*/

Map<String, dynamic>? chatToMap(Chat data) {
  return {
    'id': data.id,
    'type': data.type,
    'title': data.title,
    'description': data.description,
    'avatar_url': data.avatarUrl,
    'theme': data.theme,
    'owner_id': data.ownerId,
    'last_message_id': data.lastMessageId,
    'last_message_at': data.lastMessageAt,
    'allow_member_invite': data.allowMemberInvite,
    'allow_member_edit_info': data.allowMemberEditInfo,
    'allow_member_send_messages': data.allowMemberSendMessages,
    'slow_mode_seconds': data.slowModeSeconds,
    'members_count': data.memberCount,
    'is_pinned': data.isPinned,
    'my_role': data.myRole,
    'unread_count': data.unreadCount,
    'created_at': (data.createdAt.millisecondsSinceEpoch / 1000).round(),
    'updated_at': (data.updatedAt.millisecondsSinceEpoch / 1000).round(),
  };
}

Map<String, dynamic>? userToMap(User data) {
  return {
    'id': data.id,
    'email': data.email,
    'username': data.username,
    'display_name': data.displayName,
    'bio': data.bio,
    'avatar_url': data.avatarUrl,
    'banner_url': data.bannerUrl,
    'theme': data.theme,
    'status': data.status,
    'quote': data.quote,
    'music': data.music,
    'last_seen': data.lastSeen?.toIso8601String(),
    'created_at': (data.createdAt.millisecondsSinceEpoch / 1000).round(),
    'updated_at': (data.updatedAt.millisecondsSinceEpoch / 1000).round(),
  };
}

User userFromMap(Map<dynamic, dynamic> data) {
  return User(
    id: data['id'],
    email: data['email'],
    username: data['username'],
    displayName: data['display_name'],
    bio: data['bio'],
    avatarUrl: data['avatar_url'],
    bannerUrl: data['banner_url'],
    theme: data['theme'],
    status: data['status'],
    quote: data['quote'],
    music: data['music'],
    lastSeen: data['last_seen'] != null
        ? DateTime.parse(data['last_seen'])
        : null,
    createdAt: DateTime.fromMillisecondsSinceEpoch(data['created_at'] * 1000),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updated_at'] * 1000),
  );
}
