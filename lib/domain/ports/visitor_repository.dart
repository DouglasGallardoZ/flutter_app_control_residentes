// lib/domain/ports/visitor_repository.dart
import '../entities/visitor.dart';

abstract class VisitorRepository {
  Future<List<Visitor>> listByResidence(String residenceId);
  Future<Visitor?> findById(String id, String residenceId);
  Future<Visitor> upsert(String residenceId, Visitor visitor);
}
