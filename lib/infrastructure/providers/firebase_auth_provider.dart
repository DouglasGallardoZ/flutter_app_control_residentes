import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

class FirebaseAuthProvider {
  final FirebaseAuth auth;
  FirebaseAuthProvider(this.auth);

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = auth.currentUser;
    if (user != null) {
      return await user.getIdToken(forceRefresh);
    }
    return null;
  }

  Future<void> logout() async {
    await auth.signOut();
  }

  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  static FirebaseAuthProvider create() => FirebaseAuthProvider(FirebaseAuth.instance);
}

class ApiAuthProvider {
  final Dio dio;

  ApiAuthProvider(this.dio);

  /// Login con email y password
  /// Retorna: {access_token, usuario_id, username}
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

  /// Obtener perfil del usuario por Firebase UID
  Future<Map<String, dynamic>> obtenerPerfil(String firebaseUid) async {
    try {
      final response = await dio.get('/cuentas/perfil/$firebaseUid');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Crear cuenta de residente con Firebase
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
        'usuario_creado': 'flutter_app',
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Crear cuenta de miembro de familia con Firebase
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
        'usuario_creado': 'flutter_app',
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}