import '../ports/visitor_repository.dart';
import '../entities/visitor.dart';

class ManageVisitorUseCase {
  final VisitorRepository repo;
  ManageVisitorUseCase(this.repo);

  Future<List<Visitor>> list(String residenceId, {required int personaId}) =>
      repo.listByResidence(residenceId, personaId: personaId);

  Future<List<Visitor>> getVisitantesVivienda({required int personaId}) =>
      repo.getVisitantesVivienda(personaId: personaId);

  Future<Visitor> registerOrUpdate({
    required String residenceId,
    required String id,
    required String name,
    String? phone,
    required DateTime visitTime,
    required int personaId,
  }) async {
    final existing =
        await repo.findById(id, residenceId, personaId: personaId);
    if (existing != null) {
      final updated = existing.incVisit(visitTime);
      return repo.upsert(residenceId, updated, personaId: personaId);
    } else {
      final v = Visitor(
          id: id, name: name, phone: phone, visitCount: 1, lastVisitAt: visitTime);
      return repo.upsert(residenceId, v, personaId: personaId);
    }
  }
}
