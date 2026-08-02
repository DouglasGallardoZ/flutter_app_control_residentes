import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../domain/ports/firebase_auth_provider_port.dart';
import '../../domain/ports/api_auth_provider_port.dart';
import '../../domain/entities/auth_result.dart';

class FirebaseAuthProviderImpl implements FirebaseAuthProviderPort {
  final FirebaseAuth auth;
  FirebaseAuthProviderImpl(this.auth);

  @override
  Future<AuthResult> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Error al crear cuenta en Firebase');
      }
      return AuthResult(uid: user.uid, email: user.email);
    } on FirebaseAuthException catch (e) {
      throw Exception(mapFirebaseErrorToMessage(e.code));
    }
  }

  @override
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Error en autenticación Firebase');
      }
      return AuthResult(uid: user.uid, email: user.email);
    } on FirebaseAuthException catch (e) {
      throw Exception(mapFirebaseErrorToMessage(e.code));
    }
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = auth.currentUser;
    if (user != null) {
      return await user.getIdToken(forceRefresh);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await auth.signOut();
  }

  @override
  AuthResult? get currentUser {
    final user = auth.currentUser;
    if (user == null) return null;
    return AuthResult(uid: user.uid, email: user.email);
  }

  @override
  Stream<AuthResult?> get authStateChanges {
    return auth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthResult(uid: user.uid, email: user.email);
    });
  }

  /// Mapea códigos de error de Firebase a mensajes en español
  @override
  String mapFirebaseErrorToMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'user-not-found':
        return 'Usuario no encontrado. Verifique su correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacte con administrador';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intente más tarde';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'requires-recent-login':
        return 'Debe iniciar sesión nuevamente para continuar';
      case 'account-exists-with-different-credential':
        return 'Esta cuenta ya existe con otro método de autenticación';
      case 'invalid-api-key':
        return 'Error de configuración. Contacte con administrador';
      case 'network-request-failed':
        return 'Error de conexión. Verifique su internet';
      case 'internal-error':
        return 'Error interno. Intente nuevamente';
      default:
        return 'Error en autenticación: $code';
    }
  }

  static FirebaseAuthProviderImpl create() =>
      FirebaseAuthProviderImpl(FirebaseAuth.instance);
}

class ApiAuthProviderImpl implements ApiAuthProviderPort {
  final Dio dio;

  ApiAuthProviderImpl(this.dio);

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'username': email,
        'password': password,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> obtenerPerfil(String firebaseUid) async {
    try {
      final response = await dio.get('/cuentas/perfil/$firebaseUid');
      return response.data;
    } on DioException catch (e) {
      // Extraer mensaje de detail si existe en la respuesta del error
      final errorMessage = _extractErrorDetail(e);
      throw Exception(errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  /// Extrae el mensaje "detail" de la respuesta del error del API
  String _extractErrorDetail(DioException e) {
    try {
      if (e.response != null && e.response!.data is Map<String, dynamic>) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data.containsKey('detail')) {
          return data['detail'].toString();
        }
      }
    } catch (_) {
      // Si hay error extrayendo el detail, continuar con el mensaje general
    }
    return e.message ?? 'Error desconocido';
  }

  @override
  Future<Map<String, dynamic>> crearCuentaResidente({
    required int personaId,
    required String firebaseUid,
    required String email,
  }) async {
    try {
      final response = await dio.post('/cuentas/residente/firebase', data: {
        'persona_id': personaId,
        'firebase_uid': firebaseUid,
        'username': email,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> crearCuentaMiembro({
    required int personaId,
    required String firebaseUid,
    required String email,
  }) async {
    try {
      final response = await dio.post('/cuentas/miembro/firebase', data: {
        'persona_id': personaId,
        'firebase_uid': firebaseUid,
        'username': email,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
