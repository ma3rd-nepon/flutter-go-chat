import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  ApiService._internal();

  factory ApiService() => _instance;

  late final Dio _dio;
  late final SharedPreferences prefs;
  bool _initialized = false;

  String? _token;

  bool get isAuthorized => _token != null;

  Future<void> init() async {
    await _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    _dio = Dio(
      BaseOptions(
        baseUrl:
            'http://localhost:8080/api', // baseUrl: 'https://supernova-fzu6.onrender.com/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }

          handler.next(options);
        },
      ),
    );

    _initialized = true;
  }

  Future<void> setToken(String token) async {
    await _ensureInitialized();
    _token = token;
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    await _ensureInitialized();
    _token = null;
    await prefs.remove('token');
  }

  String _normalizeEndpoint(String endpoint) {
    return endpoint;
  }

  Future<Map<String, dynamic>?> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options
  }) async {
    await _ensureInitialized();

    try {
      final response = await _dio.get(
        _normalizeEndpoint(endpoint),
        queryParameters: queryParameters,
        options: options
      );

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'data': response.data};
    } catch (e) {
      debugPrint('GET error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    await _ensureInitialized();

    try {
      final response = await _dio.post(
        _normalizeEndpoint(endpoint),
        data: data,
      );

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'data': response.data};
    } on DioException catch (e) {
      debugPrint("STATUS: ${e.response?.statusCode}");
      debugPrint("BODY: ${e.response?.data}");
      debugPrint("REQUEST: ${e.requestOptions.data}");

      return null;
    } catch (e) {
      debugPrint('POST error: $e');

      return null;
    }
  }

  Future<Map<String, dynamic>?> put(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    await _ensureInitialized();

    try {
      final response = await _dio.put(_normalizeEndpoint(endpoint), data: data);

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'data': response.data};
    } catch (e) {
      debugPrint('PUT error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> delete(String endpoint) async {
    await _ensureInitialized();

    try {
      final response = await _dio.delete(_normalizeEndpoint(endpoint));
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'data': response.data};
    } catch (e) {
      debugPrint('DELETE error: $e');
      return null;
    }
  }
}
