// lib/infrastructure/providers/http_client.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiHttpClient {
  final Dio dio;
  final FirebaseAuth firebaseAuth;
  String? _jwtToken;
  bool _isRetrying = false;

  ApiHttpClient({
    required String baseUrl,
    required this.firebaseAuth,
  }) : dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = firebaseAuth.currentUser;
          if (user != null) {
            try {
              final idToken = await user.getIdToken();
              options.headers['Authorization'] = 'Bearer $idToken';
            } catch (e) {
              print('Error obteniendo token Firebase: $e');
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isRetrying) {
            _isRetrying = true;
            try {
              final user = firebaseAuth.currentUser;
              if (user != null) {
                final newToken = await user.getIdToken(true);
                error.requestOptions
                    .headers['Authorization'] = 'Bearer $newToken';
                final response =
                    await dio.fetch(error.requestOptions);
                _isRetrying = false;
                handler.resolve(response);
                return;
              }
            } catch (_) {
              _isRetrying = false;
              await firebaseAuth.signOut();
            }
          }
          _isRetrying = false;
          return handler.next(error);
        },
      ),
    );
  }

  void setJwtToken(String token) {
    _setToken(token);
  }

  void setToken(String token) {
    _setToken(token);
  }

  String? getJwtToken() => _jwtToken;

  String? getToken() => _jwtToken;

  void clearJwtToken() {
    _clearToken();
  }

  void clearToken() {
    _clearToken();
  }

  void _setToken(String token) {
    _jwtToken = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
    print('HTTP: Token configurado');
  }

  void _clearToken() {
    _jwtToken = null;
    dio.options.headers.remove('Authorization');
    print('HTTP: Token limpiado del interceptor');
  }
}
