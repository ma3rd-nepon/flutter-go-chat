import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
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
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

@DataClassName('ChatMember')
class ChatMembers extends Table {
  IntColumn get chatId => integer()();
  IntColumn get userId => integer()();

  // ✅ ИСПРАВЛЕНО: Добавлен NOT NULL в customConstraint + default
  TextColumn get role => text().customConstraint(
    "NOT NULL CHECK(role IN ('owner','admin','member'))",
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
    "NOT NULL CHECK(type IN ('text','photo','video','voice','document','sticker','service'))",
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
    final dbFolder = Platform.isWindows || Platform.isLinux || Platform.isMacOS
        ? Directory.current.path
        : (await getApplicationDocumentsDirectory()).path;
    final file = File(p.join(dbFolder, 'assets', 'db', name));
    // if (!await file.exists()) {
    //   try {
    //     final data = await rootBundle.load('assets/db/$name');
    //     final bytes = data.buffer.asUint8List();
    //     await file.writeAsBytes(bytes);
    //   } catch (e) {
    //     throw FileSystemException("Unable to load $name: $e");
    //   }
    // }

    // _db = MyDatabase(NativeDatabase.createInBackground(file));
    _db = MyDatabase(file);
    _isInit = true;
  }

  Stream<List<Message>> watchAllMessages(int currentChatId) {
    checkInit();
    return _db.watchAllMessages(currentChatId);
  }

  Stream<List<(Chat, Message?)>> watchAllChats() {
    checkInit();
    return _db.watchAllChats();
  }

  Future<List<Message>> getChatHistory(int currentChatId) {
    return _db.getChatHistory(currentChatId);
  }

  Future<List<Map<String, dynamic>>> getMessages(int chatId) {
    return _db.getMessages(chatId);
  }

  Future<int> sendMessage(MessagesCompanion message) {
    _db.updateChat(message.chatId.value);
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
  MyDatabase(File file) : super(_openConnection(file));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      // ✅ ЭТО ВЫЗОВЕТСЯ ПРИ ПЕРВОМ СОЗДАНИИ БД
      onCreate: (m) async {
        print('🔄 СОЗДАЁМ ТАБЛИЦЫ...');
        await m.createAll(); // 👈 ВАЖНО!
        print('✅ ТАБЛИЦЫ СОЗДАНЫ!');

        print('ДОБАВЛЯЕМ ТЕСТОВЫЕ ДАННЫЕ');

        await into(
          chats,
        ).insert(ChatsCompanion.insert(type: "group", name: Value("123")));

        await into(
          chats,
        ).insert(ChatsCompanion.insert(type: "group", name: Value("chat 2")));

        await into(
          chats,
        ).insert(ChatsCompanion.insert(type: "group", name: Value("chat 3")));

        await into(
          chats,
        ).insert(ChatsCompanion.insert(type: "group", name: Value("chat 4")));

        await into(users).insert(
          UsersCompanion.insert(username: "danil", displayName: "Danil"),
        );

        await into(
          users,
        ).insert(UsersCompanion.insert(username: "emir", displayName: "Emir"));

        await into(users).insert(
          UsersCompanion.insert(username: "zxcursed", displayName: "ZXCursed"),
        );

        await into(users).insert(
          UsersCompanion.insert(username: "rimanetcz", displayName: "Rimanec"),
        );
      },
      // ✅ ЭТО ВЫЗОВЕТСЯ ПРИ ОБНОВЛЕНИИ
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

  Future<int> addMessage(MessagesCompanion message) async {
    return into(messages).insert(message);
  }

  Future<List<Map<String, dynamic>>> getMessages(int chatId) async {
    return await (select(messages)
          ..where((msg) => msg.chatId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get()
        .then((list) => list.map((m) => m.toJson()).toList());
  }

  Stream<List<Message>> watchAllMessages(int currentChatId) {
    return (select(messages)
          ..where((msg) => msg.chatId.equals(currentChatId))
          ..orderBy([(msg) => OrderingTerm.asc(msg.createdAt)]))
        .watch();
  }

  Stream<List<(Chat, Message?)>> watchAllChats() {
    final query = select(chats)..orderBy([(c) => OrderingTerm.asc(c.updatedAt)]);

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

  Future<List<Message>> getChatHistory(int currentChatId) {
    return (select(messages)
          ..where((msg) => msg.chatId.equals(currentChatId))
          ..orderBy([(msg) => OrderingTerm.asc(msg.createdAt)]))
        .get();
  }

  Future<Chat?> getChat(int chatId) {
    return (select(
      chats,
    )..where((chat) => chat.id.equals(chatId))).getSingleOrNull();
  }

  Future<void> updateChat(int chatId) {
    return (update(chats)..where((chat) => chat.id.equals(chatId))).write(ChatsCompanion(updatedAt: Value(DateTime.now())));
  }
}
