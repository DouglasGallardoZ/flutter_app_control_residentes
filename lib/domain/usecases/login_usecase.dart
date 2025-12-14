import '../ports/auth_repository.dart';
import '../ports/account_repository.dart';

class LoginUseCase {
  final AuthRepository auth;
  final AccountRepository accounts;
  LoginUseCase(this.auth, this.accounts);

  Future<Map<String, dynamic>> call({required String identification, required String password}) async {
    final acc = await accounts.getById(identification);
    if (acc == null || acc.email == null) {
      throw Exception('Cuenta no encontrada o sin email asociado');
    }
    final user = await auth.login(email: acc.email!, password: password);
    return {
      ...user,
      'id': acc.id,
      'role': acc.role,
      'name': acc.name,
    };
  }
}
