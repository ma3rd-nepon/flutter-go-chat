import 'package:get_it/get_it.dart';
import 'cache_service.dart';
import 'database/db_service.dart' show User;

class LocalStorageService {
  LocalStorageService._internal();

  static final LocalStorageService instance = LocalStorageService._internal();

  CacheService get _cache => GetIt.instance<CacheService>();

  String? get token => _cache.getToken();

  void saveToken(String token) {
    _cache.saveToken(token);
  }

  User? get user => _cache.getUser();

  Future<void> saveUser(User user) {
    return _cache.saveUser(user);
  }

  void clearToken() {
    _cache.clearToken();
  }

  void clearUser() {
    _cache.clearUser();
  }
}