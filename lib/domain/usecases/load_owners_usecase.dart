import '../entities/owner_entity.dart';
import '../ports/owner_repository.dart';

class LoadOwnersUseCase {
  final OwnerRepository repository;

  LoadOwnersUseCase(this.repository);

  Future<List<OwnerEntity>> call({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    return repository.getOwners(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
    );
  }
}
