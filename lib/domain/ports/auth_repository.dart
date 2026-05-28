import '../entities/auth_session.dart';
import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthResult> signUpWithEmail(String email, String password);

  Future<void> logout();

  Map<String, dynamic>? get currentUser;

  Stream<Map<String, dynamic>?> get authStateChanges;

  Future<String?> getIdToken({bool forceRefresh = false});
}
