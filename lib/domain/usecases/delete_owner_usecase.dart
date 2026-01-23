import '../ports/owner_repository.dart';

class DeleteOwnerUseCase {
  final OwnerRepository repository;

  DeleteOwnerUseCase(this.repository);

  Future<void> call(int ownerId) async {
    return repository.deleteOwner(ownerId);
  }
}
