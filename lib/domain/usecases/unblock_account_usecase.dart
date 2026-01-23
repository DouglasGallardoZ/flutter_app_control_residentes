import '../ports/admin_account_repository.dart';

class UnblockAccountUseCase {
  final AdminAccountRepository repository;

  UnblockAccountUseCase(this.repository);

  Future<void> call({
    required int accountId,
    required String reason,
    bool cascada = false,
  }) {
    return repository.unblockAccount(accountId, reason, cascada: cascada);
  }
}
