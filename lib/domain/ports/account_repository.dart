import '../entities/account.dart';

abstract class AccountRepository {
  Future<Account> register(Account account);
  Future<Account?> getById(String id);
  Future<void> updateEmail(String id, String newEmail);
}
