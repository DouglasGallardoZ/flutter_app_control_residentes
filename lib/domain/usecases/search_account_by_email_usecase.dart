import '../ports/admin_account_repository.dart';

class SearchAccountByEmailUseCase {
  final AdminAccountRepository repository;

  SearchAccountByEmailUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call({required String email}) {
    return repository.searchByEmail(email);
  }
}
