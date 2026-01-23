import '../ports/admin_account_repository.dart';

class SearchAccountByLocationUseCase {
  final AdminAccountRepository repository;

  SearchAccountByLocationUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call({
    required String manzana,
    required String villa,
  }) {
    return repository.searchByLocation(manzana, villa);
  }
}
