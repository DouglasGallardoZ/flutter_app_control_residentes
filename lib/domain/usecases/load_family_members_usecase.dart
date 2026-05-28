import '../ports/account_repository.dart';
import '../entities/account.dart';

class LoadFamilyMembersUseCase {
  final AccountRepository repository;
  LoadFamilyMembersUseCase(this.repository);

  Future<List<Account>> execute(dynamic residenceId, String role) async {
    return await repository.listByResidenceAndRole(residenceId, role);
  }
}
