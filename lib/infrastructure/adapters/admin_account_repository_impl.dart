import '../../domain/ports/admin_account_repository.dart';
import '../../domain/ports/account_management/account_management_api_port.dart';

class AdminAccountRepositoryImpl implements AdminAccountRepository {
  final AccountManagementApiPort accountManagementApi;

  AdminAccountRepositoryImpl({required this.accountManagementApi});

  @override
  Future<List<Map<String, dynamic>>> searchByEmail(String email) async {
    final response = await accountManagementApi.getUserByEmail(correo: email);
    return [response];
  }

  @override
  Future<List<Map<String, dynamic>>> searchByLocation(
      String manzana, String villa) async {
    final response = await accountManagementApi.getUsersByVivienda(
        manzana: manzana, villa: villa);
    return response.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> blockAccount(int accountId, String reason,
      {bool cascada = false}) async {
    await accountManagementApi.blockAccount(accountId, reason,
        cascada: cascada);
  }

  @override
  Future<void> unblockAccount(int accountId, String reason,
      {bool cascada = false}) async {
    await accountManagementApi.unblockAccount(accountId, reason,
        cascada: cascada);
  }

  @override
  Future<void> deleteAccount(int accountId, String motivo) async {
    await accountManagementApi.deleteAccount(
        accountId, reason: motivo);
  }
}
