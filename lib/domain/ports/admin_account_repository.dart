abstract class AdminAccountRepository {
  Future<List<Map<String, dynamic>>> searchByEmail(String email);
  Future<List<Map<String, dynamic>>> searchByLocation(String manzana, String villa);
  Future<void> blockAccount(int accountId, String reason, {bool cascada = false});
  Future<void> unblockAccount(int accountId, String reason, {bool cascada = false});
  Future<void> deleteAccount(int accountId, String motivo);
  // Future<void> resetPassword(int accountId, String newPassword);
}
