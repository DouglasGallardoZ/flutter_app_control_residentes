import '../ports/owner_repository.dart';

class BlockOwnerUseCase {
  final OwnerRepository repository;

  BlockOwnerUseCase(this.repository);

  Future<void> call(int ownerId, String reason) async {
    return repository.blockOwner(ownerId, reason);
  }
}
