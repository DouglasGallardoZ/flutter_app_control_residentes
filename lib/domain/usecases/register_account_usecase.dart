import '../ports/account_repository.dart';
import '../entities/account.dart';

class RegisterAccountUseCase {
  final AccountRepository repo;
  RegisterAccountUseCase(this.repo);
  Future<Account> call(Account account) => repo.register(account);
}