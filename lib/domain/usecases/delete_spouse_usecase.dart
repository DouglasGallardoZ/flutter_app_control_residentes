import '../ports/owner_repository.dart';

class DeleteSpouseUseCase {
  final OwnerRepository repository;
  DeleteSpouseUseCase(this.repository);

  Future<void> execute(int spouseId) async {
    await repository.deleteSpouse(spouseId);
  }
}
