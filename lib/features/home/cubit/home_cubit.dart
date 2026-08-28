import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:drift/drift.dart' show Value;

import '../../../core/utils/database/db_service.dart';
import '../../../core/utils/polling/http.dart';
import '../../../core/utils/local_storage_service.dart';
import '../../../core/utils/polling/websocket.dart';

import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(String userId) : super(HomeState.initial()) {
    init(userId);
  }

  final _db = DatabaseService();
  final _http = ApiService();
  final _ws = WebSocketService();
  final storage = LocalStorageService.instance;
  StreamSubscription? _chatSub;
  StreamSubscription<List<(Chat, Message)>>? _msgSub;

  Future<void> init(String userId) async {
    await _db.openDB('database_$userId.db');
    await loadHomeData();
  }

  Future<void> loadHomeData() async {
    emit(const HomeState.loading());

    await _chatSub?.cancel();
    await _msgSub?.cancel();

    try {
      final user = storage.user;
      if (user != null) {
        _ws.init();

        await updateChats();

        _chatSub = _db.watchAllChats().listen((chats) {
          emit(HomeState.loaded(chats: chats, user: user));
        });
      } else {
        throw Exception("User not authorized");
      }
    } catch (e) {
      emit(HomeState.error(message: e.toString(), previousState: state));
    }
  }

  Future<void> updateChats() async {
    final response = await _http.get('/chats');

    if (response == null || !response['success']) {
      emit(
        HomeState.error(
          message: "Error^ Response is null",
          previousState: state,
        ),
      );
      return;
    } else {
      final items = response['data']['items'];
      if (items is List) {
        final chats = items.map((mapChat) => chatFromMap(mapChat)).toList();
        await _db.batchChats(chats);
      }
    }
  }

  void createChat({
    required String title,
    required String type,
    required List<String> membersId,
  }) async {
    final currentState = state;
    if (currentState is HomeLoadedState) {
      try {
        final response = await _http.post(
          '/chats',
          data: {'title': title, 'type': type, 'members_ids': membersId},
        );

        if (response == null || response['error'] != null) {
          String message = 'Response Error';
          response?['error'] != null
              ? message += ': ${response?["error"]}'
              : message += ': Null Response';
          emit(HomeState.error(message: message, previousState: state));
          return;
        } else {
          final chat = response['data'];
          if (chat is Map) {
            final newChat = chatFromMap(chat);

            await _db.createChat(chat: newChat);
          }
        }
      } catch (e) {
        emit(HomeState.error(message: e.toString(), previousState: state));
      }
    }
  }

  Future<void> batchChat(String chatId) async {
    try {
      final response = await _http.get('/chats/$chatId/messages');

      if (response == null || !response['success']) {
        emit(HomeState.error(message: "Response is null", previousState: state));
        return;
      } else {
        final items = response['data']['items'] as List;
        final List<Message> messages = items.map((mapMsg) => messagefromMap(mapMsg)).toList();

        await _db.batchChat(chatId, messages);
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      return;
    }
  }
  
  Future<void> sendMessage(MessagesCompanion msg) async {
    print('sending message');
    // TODO сделать Message | MessageCompanion
    if (_http.isAuthorized) {
      final response = await _http.post(
        '/chats/${msg.chatId.value}/messages',
        data: messageToMap(companion: msg),
      );

      print('response given');
      print('RESPONSE IS $response');

      if (response == null || !response['success']) {
        print('response null');
        emit(
          HomeState.error(
            message: "Error during sending message",
            previousState: state,
          ),
        );
        return;
      }

      final message = messagefromMap(response['data']);
      await _db.sendMessage(message);
      print('message sent to db');
    }
  }

  Map<String, dynamic>? getUser() {
    final cachedUser = storage.user;
    if (cachedUser != null) {
      return userToMap(cachedUser);
    }
    return null;
  }

  Future<Chat?> getChat(String chatId) async {
    return await _db.getChat(chatId);
  }

  // StreamSubscription messageStream(String chatId) {
  //   return _db.watchAllMessages(chatId).listen((message) {});
  // }
}
