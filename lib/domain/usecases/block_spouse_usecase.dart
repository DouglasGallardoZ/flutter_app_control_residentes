import '../ports/owner_repository.dart';

class BlockSpouseUseCase {
  final OwnerRepository repository;
  BlockSpouseUseCase(this.repository);

  Future<void> execute(int spouseId, bool block) async {
    await repository.blockSpouse(spouseId, block);
  }
}
