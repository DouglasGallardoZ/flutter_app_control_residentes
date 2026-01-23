import '../ports/resident_repository.dart';

class ReactivateResidentUseCase {
  final ResidentRepository repository;

  ReactivateResidentUseCase(this.repository);

  Future<void> call(int residentId, String reason) async {
    return repository.reactivateResident(
      personaId: residentId,
      reason: reason,
    );
  }
}
