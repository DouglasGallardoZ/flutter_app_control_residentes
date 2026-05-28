import '../ports/owner_repository.dart';
import '../entities/conyuge_entity.dart';

class GetOwnerWithSpousesUseCase {
  final OwnerRepository repository;
  GetOwnerWithSpousesUseCase(this.repository);

  Future<OwnerWithSpousesEntity> execute(int ownerId) async {
    return await repository.getOwnerWithSpouses(ownerId);
  }
}
