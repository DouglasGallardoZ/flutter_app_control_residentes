import '../../domain/ports/account_repository.dart';
import '../../domain/entities/account.dart';

class LoadFamilyMembersUseCase {
  final AccountRepository repo;
  LoadFamilyMembersUseCase(this.repo);

  Future<List<Account>> call(String residenceId) async {
    return await repo.listByResidenceAndRole(residenceId, 'family');
  }
}
