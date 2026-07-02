import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/ports/session_cleanup_port.dart';
import '../../domain/ports/firebase_auth_provider_port.dart';
import '../providers/http_client.dart';

class SessionCleanupImpl implements SessionCleanupPort {
  final FirebaseAuthProviderPort authProvider;
  final ApiHttpClient generalHttpClient;
  final ApiHttpClient? biometryHttpClient;

  SessionCleanupImpl({
    required this.authProvider,
    required this.generalHttpClient,
    this.biometryHttpClient,
  });

  @override
  Future<Map<String, bool>> clearAllSessions() async {
    final results = <String, bool>{};

    results['backend_logout'] = await _logoutBackend();
    results['firebase_signout'] = await _signOutFirebase(retries: 2);
    results['clear_dio_general'] = _clearDioHeaders(generalHttpClient);
    if (biometryHttpClient != null) {
      results['clear_dio_biometry'] =
          _clearDioHeaders(biometryHttpClient!);
    }
    results['clear_shared_prefs'] = await _clearSharedPreferences();
    results['clear_secure_storage'] = await _clearSecureStorage();
    results['propagation_delay'] = await _waitPropagation();

    print(
        ' LOGOUT: resultados de limpieza -> $results');
    return results;
  }

  Future<bool> _logoutBackend() async {
    try {
      print(' LOGOUT: notificando backend...');
      final response = await generalHttpClient.dio.post(
        '/auth/logout',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      print(
          ' LOGOUT: backend no disponible (${e.response?.statusCode}) - continuando');
      return false;
    } catch (e) {
      print(' LOGOUT: error al notificar backend - continuando');
      return false;
    }
  }

  Future<bool> _signOutFirebase({int retries = 2}) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        print(
            ' LOGOUT: cerrando sesión Firebase (intento ${attempt + 1})...');
        await authProvider.logout();
        print(' LOGOUT: sesión Firebase cerrada exitosamente');
        return true;
      } catch (e) {
        print(
            ' LOGOUT: error en signOut Firebase (intento ${attempt + 1}): $e');
        if (attempt < retries) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
    return false;
  }

  bool _clearDioHeaders(ApiHttpClient client) {
    try {
      print(' LOGOUT: limpiando headers de autenticación HTTP...');
      client.clearToken();
      return true;
    } catch (e) {
      print(
          ' LOGOUT: error al limpiar headers HTTP - continuando');
      return false;
    }
  }

  Future<bool> _clearSharedPreferences() async {
    try {
      print(' LOGOUT: limpiando SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = prefs.getKeys().where(
          (k) => k.toLowerCase().contains('token') ||
              k.toLowerCase().contains('auth') ||
              k.toLowerCase().contains('session'));
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      print(
          ' LOGOUT: SharedPreferences limpiado (${keysToRemove.length} claves)');
      return true;
    } catch (e) {
      print(
          ' LOGOUT: error al limpiar SharedPreferences - continuando');
      return false;
    }
  }

  Future<bool> _clearSecureStorage() async {
    if (kIsWeb) {
      print(
          ' LOGOUT: FlutterSecureStorage no soportado en web - omitiendo');
      return false;
    }
    try {
      print(' LOGOUT: limpiando FlutterSecureStorage...');
      const storage = FlutterSecureStorage();
      await storage.deleteAll();
      print(' LOGOUT: FlutterSecureStorage limpiado');
      return true;
    } catch (e) {
      print(
          ' LOGOUT: error al limpiar FlutterSecureStorage - continuando');
      return false;
    }
  }

  Future<bool> _waitPropagation() async {
    try {
      print(
          ' LOGOUT: esperando propagación de Firebase (100ms)...');
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (_) {
      return false;
    }
  }
}
