import '../entities/owner_entity.dart';
import '../ports/owner_repository.dart';

class LoadOwnersByLocationUseCase {
  final OwnerRepository repository;

  LoadOwnersByLocationUseCase(this.repository);

  Future<List<OwnerEntity>> call({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  }) async {
    return repository.getOwnersByLocation(
      manzana: manzana,
      villa: villa,
      page: page,
      pageSize: pageSize,
    );
  }
}
