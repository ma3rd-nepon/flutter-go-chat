import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:async';
import 'dart:io';

part 'db_service.g.dart';

@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get phone => text().unique().nullable()();
  TextColumn get displayName => text()();
  TextColumn get surname => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get bio => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSeen => dateTime().nullable()();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
}

@DataClassName('Chat')
class Chats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();

  TextColumn get type => text().customConstraint(
    "NOT NULL CHECK(type IN ('private','group','channel'))",
  )();

  IntColumn get pinnedMessageId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

@DataClassName('ChatMember')
class ChatMembers extends Table {
  IntColumn get chatId => integer()();
  IntColumn get userId => integer()();

  // ✅ ИСПРАВЛЕНО: Добавлен NOT NULL в customConstraint + default
  TextColumn get role => text().customConstraint(
    "NOT NULL CHECK(role IN ('owner'','admin','member'))",
  )();

  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get lastReadMessage => integer().nullable()();
  DateTimeColumn get mutedUntil => dateTime().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {chatId, userId};
}

@DataClassName('Message')
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chatId => integer()();
  IntColumn get senderId => integer()();
  IntColumn get replyTo => integer().nullable()();

  TextColumn get type => text().customConstraint(
    "NOT NULL CHECK(type IN ('text','photo','video','voice','document','sticker'','service'))",
  )();

  TextColumn get content => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get editedAt => dateTime().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
}

@DataClassName('Attachment')
class Attachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get messageId => integer()();
  TextColumn get fileName => text().nullable()();
  TextColumn get filePath => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get fileSize => integer().nullable()();
  DateTimeColumn get uploadedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('MessageState')
class MessageStates extends Table {
  IntColumn get messageId => integer()();
  IntColumn get userId => integer()();

  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK(status IN ('sent', 'read', 'delivered'))",
  )();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {messageId, userId};
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  late final MyDatabase _db;
  bool _isInit = false;

  void checkInit() {
    if (!_isInit) {
      throw SqliteException(
        extendedResultCode: 1,
        message: "Database isn't initialized",
      );
    }
  }

  Future<void> openDB(String name) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, name));

    if (!await file.exists()) {
      try {
        final data = await rootBundle.load('assets/db/$name');
        final bytes = data.buffer.asUint8List();
        await file.writeAsBytes(bytes);
      } catch (e) {
        throw FileSystemException("Unable to load $name: $e");
      }
    }

    _db = MyDatabase(NativeDatabase.createInBackground(file));
    _isInit = true;
  }

  Stream<List<Message>> watchAllMessages(int currentChatId) {
    checkInit();
    return _db.watchAllMessages(currentChatId);
  }

  Stream<List<Chat>> watchAllChats(int currentUserId) {
    checkInit();
    return _db.watchAllChats(currentUserId);
  }

  Future<List<Message>> getChatHistory(int currentChatId) {
    return _db.getChatHistory(currentChatId);
  }

  Future<List<Map<String, dynamic>>> getMessages(int chatId) {
    return _db.getMessages(chatId);
  }

  Future<int> sendMessage(MessagesCompanion message) {
    return _db.addMessage(message);
  }

  Future<Chat?> getChat(int chatId) {
    return _db.getChat(chatId);
  }
}

@DriftDatabase(
  tables: [Users, Chats, ChatMembers, Messages, Attachments, MessageStates],
)
class MyDatabase extends _$MyDatabase {
  MyDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future<int> addMessage(MessagesCompanion message) {
    return into(messages).insert(message);
  }

  Future<List<Map<String, dynamic>>> getMessages(int chatId) async {
    return await (select(messages)
          ..where((msg) => msg.chatId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .get()
        .then((list) => list.map((m) => m.toJson()).toList());
  }

  Stream<List<Message>> watchAllMessages(int currentChatId) {
    return (select(messages)
          ..where((msg) => msg.chatId.equals(currentChatId))
          ..orderBy([(msg) => OrderingTerm.asc(msg.createdAt)]))
        .watch();
  }

  Stream<List<Chat>> watchAllChats(int currentUserId) {
    return (select(
      chats,
    )..orderBy([(chat) => OrderingTerm.asc(chat.updatedAt)])).watch();
  }

  Future<List<Message>> getChatHistory(int currentChatId) {
    return (select(messages)
          ..where((msg) => msg.chatId.equals(currentChatId))
          ..orderBy([(msg) => OrderingTerm.asc(msg.createdAt)]))
        .get();
  }

  Future<Chat?> getChat(int chatId) {
    return (select(chats)..where((chat) => chat.id.equals(chatId))).getSingleOrNull();
  }
}
