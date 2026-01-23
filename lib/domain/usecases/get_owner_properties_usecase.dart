import '../ports/owner_repository.dart';

class GetOwnerPropertiesUseCase {
  final OwnerRepository repository;

  GetOwnerPropertiesUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(int ownerId) async {
    return repository.getOwnerProperties(ownerId);
  }
}
