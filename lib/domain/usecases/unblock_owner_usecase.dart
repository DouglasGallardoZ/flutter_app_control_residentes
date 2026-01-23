import '../ports/owner_repository.dart';

class UnblockOwnerUseCase {
  final OwnerRepository repository;

  UnblockOwnerUseCase(this.repository);

  Future<void> call(int ownerId, String reason) async {
    return repository.unblockOwner(ownerId, reason);
  }
}
