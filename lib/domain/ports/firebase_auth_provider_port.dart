import '../entities/auth_result.dart';

/// Puerto para operaciones de autenticación con Firebase
abstract class FirebaseAuthProviderPort {
  /// Registra un nuevo usuario con email y contraseña
  Future<AuthResult> signUpWithEmail(String email, String password);

  /// Inicia sesión con email y contraseña
  Future<AuthResult> signInWithEmail(String email, String password);

  /// Obtiene el token de identificación de Firebase
  Future<String?> getIdToken({bool forceRefresh = false});

  /// Cierra la sesión actual
  Future<void> logout();

  /// Obtiene el usuario actual autenticado
  AuthResult? get currentUser;

  /// Stream de cambios en el estado de autenticación
  Stream<AuthResult?> get authStateChanges;

  /// Mapea códigos de error de Firebase a mensajes en español
  String mapFirebaseErrorToMessage(String code);
}
