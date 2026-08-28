import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/database/db_service.dart' show User;

part 'auth_state.freezed.dart';

/// Auth Screen Statement 
@freezed
class AuthState with _$AuthState {
  /// app launch - checking session
  const factory AuthState.initial() = AuthInitialState;

  /// async operation in progress
  const factory AuthState.loading() = AuthLoadingState;

  const factory AuthState.authorize() = AuthAuthorizingState;

  /// OTP verification
  const factory AuthState.otpSent({
    required (String, String) data,
  }) = AuthOtpSentState;

  const factory AuthState.passwordSetup({
    required (String, String) data,
  }) = AuthPasswordSetup;

  /// Setup profile if new account registered
  const factory AuthState.profileSetup({
    required (String, String) data,
  }) = AuthProfileSetupState;

  /// fully authenticated
  const factory AuthState.authenticated({
    required (User, String) fullUser
  }) = AuthAuthenticatedState;

  /// Any error occured
  const factory AuthState.error({
    required String message,
    required AuthState previousState
  }) = AuthErrorState;
}