import '../ports/account_repository.dart';

class UpdateEmailUseCase {
  final AccountRepository repository;
  UpdateEmailUseCase(this.repository);

  Future<void> execute(String id, String newEmail) async {
    await repository.updateEmail(id, newEmail);
  }
}
