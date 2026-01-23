import '../ports/admin_account_repository.dart';

class DeleteAccountUseCase {
  final AdminAccountRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<void> call({required int accountId}) {
    return repository.deleteAccount(accountId);
  }
}
