import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:async';
import 'dart:io';


@DataClassName('User')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();  TextColumn get username => text().unique()();
  TextColumn get phone => text().unique().nullable()();
  TextColumn get displayName => text()();
  TextColumn get surname => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get bio => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSeen => dateTime().nullable()();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
}

// Таблица Chats
@DataClassName('Chat')
class Chats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().nullable()();
  TextColumn get type => text().customConstraint('CHECK(type IN ("private","group","channel"))')();
  IntColumn get pinnedMessageId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

// Таблица ChatMembers
@DataClassName('ChatMember')
class ChatMembers extends Table {
  IntColumn get chatId => integer()();
  IntColumn get userId => integer()();
  TextColumn get role => text().withDefault(const Constant('member')).customConstraint('CHECK(role IN ("owner","admin","member"))')();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get lastReadMessage => integer().nullable()();
  DateTimeColumn get mutedUntil => dateTime().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {chatId, userId};
}

// Таблица Messages
@DataClassName('Message')
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chatId => integer()();
  IntColumn get senderId => integer()();
  IntColumn get replyTo => integer().nullable()();
  TextColumn get type => text().withDefault(const Constant('text')).customConstraint('CHECK(type IN ("text","photo","video","voice","document","sticker","service"))')();
  TextColumn get content => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get editedAt => dateTime().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
}

// Таблица Attachments
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

// Таблица MessageStatus
@DataClassName('MessageStatus')
class MessageStatus extends Table {
  IntColumn get messageId => integer()();
  IntColumn get userId => integer()();
  TextColumn get status => text().customConstraint('CHECK(status IN ("sent","delivered","read"))')();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {messageId, userId};
}

class DatabaseConfig {
  final String assetPath;
  final String dbName;
  final int version;

  const DatabaseConfig({
    this.assetPath = 'assets/db/database.db',
    this.dbName = 'database.db',
    this.version = 1,
  });
}

// @DriftDatabase(tables: [Users, Chats, ChatMembers, Messages, Attachments, MessageStatus])
class DatabaseService {
  final DatabaseConfig _config = DatabaseConfig();
  
  LazyDatabase openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, _config.dbName));

      if (!await file.exists()) {
        final blob = await rootBundle.load(_config.assetPath);
        final buffer = blob.buffer;

        await file.writeAsBytes(buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes));
      }

      // if (Platform.isAndroid) {
      //   await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      // }
      // final cachebase = (await getTemporaryDirectory()).path();
      // sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createBackgroundConnection(file);
    });
  }

  
}

