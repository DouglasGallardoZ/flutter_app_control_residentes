import '../entities/visitor.dart';

abstract class VisitorRepository {
  Future<List<Visitor>> listByResidence(String residenceId,
      {required int personaId});
  Future<Visitor?> findById(String id, String residenceId,
      {required int personaId});
  Future<Visitor> upsert(String residenceId, Visitor visitor,
      {required int personaId});
  Future<List<Visitor>> getVisitantesVivienda({required int personaId});
}
