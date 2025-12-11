abstract class AuthRepository {
  Future<Map<String, dynamic>> login({required String id, required String password});
  Future<void> logout();
}
