import '../ports/admin_account_repository.dart';

class BlockAccountUseCase {
  final AdminAccountRepository repository;

  BlockAccountUseCase(this.repository);

  Future<void> call({
    required int accountId,
    required String reason,
    bool cascada = false,
  }) {
    return repository.blockAccount(accountId, reason, cascada: cascada);
  }
}
