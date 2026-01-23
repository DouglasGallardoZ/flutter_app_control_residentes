import '../ports/admin_account_repository.dart';

class ResetPasswordUseCase {
  final AdminAccountRepository repository;

  ResetPasswordUseCase(this.repository);

  // Future<void> call({
  //   required int accountId,
  //   required String newPassword,
  // }) {
  //   return repository.resetPassword(accountId, newPassword);
  // }
}
