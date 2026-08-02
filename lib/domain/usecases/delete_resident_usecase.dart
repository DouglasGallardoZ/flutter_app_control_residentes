import '../ports/resident_repository.dart';

class DeleteResidentUseCase {
  final ResidentRepository repository;

  DeleteResidentUseCase(this.repository);

  Future<void> call(int residentId, String motivo) async {
    return repository.deleteResident(residentId, motivo);
  }
}
