import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/local_storage_service.dart';
import '../../../core/utils/database/db_service.dart' show User;
import '../../../core/utils/polling/http.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.initial()) {
    checkSession();
  }

  User? _currentUser;
  final http = ApiService();

  void checkSession() {
    final cachedUserToken = LocalStorageService.instance.token;
    _currentUser = LocalStorageService.instance.user;

    if (_currentUser != null && cachedUserToken != null) {
      emit(AuthState.authenticated(fullUser: (_currentUser!, cachedUserToken)));
    } else {
      emit(const AuthState.initial());
    }
  }

  // (User, String) getUser() {
  //   final cachedUserToken = LocalStorageService.instance.token;

  //   if (_currentUser == null || cachedUserToken == null)
  //     throw Exception('Not authorized');

  //   return (_currentUser!, cachedUserToken);
  // }

  Future<void> submitEmail({required (String, String) data}) async {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]{1,64}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    final email = data.$1;
    if (email.trim().isEmpty || !emailRegex.hasMatch(email)) {
      emit(
        AuthState.error(message: "Invalid email", previousState: state),
      ); // TODO AppStrings
      return;
    }

    emit(const AuthState.loading());

    await Future.delayed(const Duration(seconds: 3)); // TODO Email Verify

    final (String, String) newData = (email, data.$2);

    emit(AuthState.otpSent(data: newData));
  }

  Future<void> verifyOtp({required String otp, required (String, String) data}) async {
    if (otp.length != 6) {
      emit(
        AuthState.error(message: "Invalid OTP", previousState: state),
      ); // TODO AppStrings
      return;
    }

    emit(const AuthState.loading());

    await Future.delayed(const Duration(seconds: 2)); // TODO OTP Verify

    emit(AuthState.passwordSetup(data: data));
  }

  Future<void> createPassword({ required (String, String) data }) async {
    final password = data.$2;
    if (password.trim().isEmpty) {
      emit(AuthState.error(message: 'Empty password', previousState: state));
      return;
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(password)) {
      emit(AuthState.error(message: 'Bad password', previousState: state));
    }

    emit(const AuthState.loading());

    // final result = await http.post('/register', data: {});

    // final token = '123_token'; // TODO WS polling

    // LocalStorageService.instance.saveToken(token);
    emit(AuthState.profileSetup(data: (data.$1, password)));
  }

  Future<void> signIn({required (String, String) data}) async {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]{1,64}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    final email = data.$1;
    if (email.trim().isEmpty || !emailRegex.hasMatch(email)) {
      emit(
        AuthState.error(message: "Invalid email", previousState: state),
      ); // TODO AppStrings
      return;
    }

    final RegExp passRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    final password = data.$2;
    if (password.trim().isEmpty || !passRegex.hasMatch(password)) {
      emit(AuthState.error(message: "Invalid password", previousState: state));
      return;
    }

    emit(const AuthState.loading());

    final result = await http.post('/auth/login', data: {'email': email, 'password': password});

    parseResponse(result);
    }

  Future<void> submitProfile({
    required String displayName,
    required String photoPath,
    required (String, String) data,
  }) async {
    if (displayName.trim().isEmpty) {
      emit(
        AuthState.error(
          message: 'Empty Name', // TODO AppStrings
          previousState: state,
        ),
      );

      return;
    }

    emit(const AuthState.loading());

    final result = await http.post(
      '/auth/register',
      data: {
        'email': data.$1,
        'password': data.$2,
        'display_name': displayName,
      },
    );

    parseResponse(result);
  }

  Future<void> parseResponse(Map<String, dynamic>? result) async {
    if (result == null) {
      emit(AuthState.error(message: 'Error during registration', previousState: state));
    } else if (result['error'] != null) {
      emit(AuthState.error(message: result['error'], previousState: state));
    } else {
      final accessToken = result['data']['access_token']?.toString();
      if (accessToken == null || accessToken.isEmpty) {
        emit(AuthState.error(message: 'Error during authorization', previousState: state));
        return;
      }
      await http.setToken(accessToken);

      final user = result['data']['user'];
      if (user is Map) {
        _currentUser = User(
          id: user['id'],
          email: user['email'],
          username: user['username'],
          displayName: user['display_name'],
          bio: user['bio'],
          status: user['status'],
          lastSeen: user['last_seen'],
          createdAt: DateTime.fromMillisecondsSinceEpoch(user['created_at'] * 1000),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(user['updated_at'] * 1000)
        );
      }
      if (_currentUser != null) {
        await LocalStorageService.instance.saveUser(_currentUser!);
        LocalStorageService.instance.saveToken(accessToken);
        emit(AuthState.authenticated(fullUser: (_currentUser!, accessToken)));
      }
    }
  }

  // Navigation helpers
  void proceedToEmail() {
    if (state is! AuthInitialState) return;
    emit(const AuthState.initial());
  }

  void clearError() {
    final s = state;
    if (s is AuthErrorState) emit(s.previousState);
  }

  void logout() {
    LocalStorageService.instance.clearToken();
    LocalStorageService.instance.clearUser();
    _currentUser = null;
    emit(const AuthState.initial());
  }
}
