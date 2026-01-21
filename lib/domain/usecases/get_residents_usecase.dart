import '../entities/account.dart';
import '../ports/admin_repository.dart';

class GetResidentsUseCase {
  final AdminRepository adminRepository;

  GetResidentsUseCase(this.adminRepository);

  Future<List<Account>> call({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? statusFilter,
  }) async {
    return await adminRepository.getResidents(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      statusFilter: statusFilter,
    );
  }
}
