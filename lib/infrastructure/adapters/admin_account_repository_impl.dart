import '../../infrastructure/providers/admin_api.dart';
import '../../domain/ports/admin_account_repository.dart';

class AdminAccountRepositoryImpl implements AdminAccountRepository {
  final AdminApi adminApi;

  AdminAccountRepositoryImpl({required this.adminApi});

  @override
  Future<List<Map<String, dynamic>>> searchByEmail(String email) async {
    final response = await adminApi.getUserByEmail(correo: email);
    return [response];
  }

  @override
  Future<List<Map<String, dynamic>>> searchByLocation(String manzana, String villa) async {
    final response = await adminApi.getUsersByVivienda(manzana: manzana, villa: villa);
    return response.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> blockAccount(int accountId, String reason, {bool cascada = false}) async {
    await adminApi.blockAccount(accountId, reason, cascada: cascada);
  }

  @override
  Future<void> unblockAccount(int accountId, String reason, {bool cascada = false}) async {
    await adminApi.unblockAccount(accountId, reason, cascada: cascada);
  }

  @override
  Future<void> deleteAccount(int accountId) async {
    await adminApi.deleteAccount(accountId);
  }

  // @override
  // Future<void> resetPassword(int accountId, String newPassword) async {
  //   await adminApi.resetPassword(accountId, newPassword);
  // }
}
