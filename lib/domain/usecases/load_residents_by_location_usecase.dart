import '../ports/resident_repository.dart';

class LoadResidentsByLocationUseCase {
  final ResidentRepository repository;

  LoadResidentsByLocationUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call({
    required String manzana,
    required String villa,
  }) async {
    return repository.getResidentsByLocation(
      manzana: manzana,
      villa: villa,
    );
  }
}
