import '../ports/account_repository.dart';
import '../entities/account.dart';

class RegisterAccountUseCase {
  final AccountRepository repository;
  RegisterAccountUseCase(this.repository);

  Future<Account> execute(Account account) async {
    return await repository.register(account);
  }
}
