import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/database/db_service.dart' show Chat, Message, User;

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeInitialState;

  const factory HomeState.loading() = HomeLoadingState;

  const factory HomeState.loaded({
    required List<(Chat, Message?)> chats,
    required User user
  }) = HomeLoadedState;

  const factory HomeState.error({
    required String message,
    required HomeState previousState
  }) = HomeErrorState;

  // TODO HomeState.notification ; HomeState.warning
}