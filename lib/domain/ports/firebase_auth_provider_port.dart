import 'package:firebase_auth/firebase_auth.dart';

/// Puerto para operaciones de autenticación con Firebase
abstract class FirebaseAuthProviderPort {
  /// Registra un nuevo usuario con email y contraseña
  Future<UserCredential> signUpWithEmail(String email, String password);

  /// Inicia sesión con email y contraseña
  Future<UserCredential> signInWithEmail(String email, String password);

  /// Obtiene el token de identificación de Firebase
  Future<String?> getIdToken({bool forceRefresh = false});

  /// Cierra la sesión actual
  Future<void> logout();

  /// Obtiene el usuario actual autenticado
  User? get currentUser;

  /// Stream de cambios en el estado de autenticación
  Stream<User?> get authStateChanges;

  /// Mapea códigos de error de Firebase a mensajes en español
  String mapFirebaseErrorToMessage(String code);
}
