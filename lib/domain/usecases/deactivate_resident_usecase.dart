import '../ports/resident_repository.dart';

class DeactivateResidentUseCase {
  final ResidentRepository repository;

  DeactivateResidentUseCase(this.repository);

  Future<void> call(int residentId, String reason) async {
    return repository.deactivateResident(
      personaId: residentId,
      reason: reason,
    );
  }
}
