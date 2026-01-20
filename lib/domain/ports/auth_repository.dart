abstract class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Map<String, dynamic>? get currentUser;

  Stream<Map<String, dynamic>?> get authStateChanges;

  Future<String?> getIdToken({bool forceRefresh = false});
}
