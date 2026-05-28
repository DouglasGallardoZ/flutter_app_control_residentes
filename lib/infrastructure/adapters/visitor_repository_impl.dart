import '../../domain/entities/visitor.dart';
import '../../domain/ports/visitor_repository.dart';
import '../providers/visitor_api.dart';

class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorApi api;

  VisitorRepositoryImpl({required this.api});

  @override
  Future<List<Visitor>> listByResidence(
    String residenceId, {
    required int personaId,
  }) async {
    try {
      final response =
          await api.listByResidence(personaId: personaId);
      final data = response['data'] as List<dynamic>? ?? [];
      return data.map((item) {
        final map = item as Map<String, dynamic>;
        return Visitor(
          id: map['id']?.toString() ?? '',
          name: map['nombre']?.toString() ?? '',
          phone: map['telefono'],
          visitCount: map['cantidad_visitas'] as int? ?? 0,
          lastVisitAt: map['ultima_visita'] != null
              ? DateTime.tryParse(map['ultima_visita'].toString())
              : null,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Visitor?> findById(
    String id,
    String residenceId, {
    required int personaId,
  }) async {
    try {
      final response = await api.findById(
        personaId: personaId,
        visitantId: id,
      );
      if (response['data'] == null) return null;
      final map = response['data'] as Map<String, dynamic>;
      return Visitor(
        id: map['id']?.toString() ?? '',
        name: map['nombre']?.toString() ?? '',
        phone: map['telefono'],
        visitCount: map['cantidad_visitas'] as int? ?? 0,
        lastVisitAt: map['ultima_visita'] != null
            ? DateTime.tryParse(map['ultima_visita'].toString())
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Visitor> upsert(
    String residenceId,
    Visitor visitor, {
    required int personaId,
  }) async {
    try {
      final response = await api.upsert(
        personaId: personaId,
        id: visitor.id,
        nombre: visitor.name,
        telefono: visitor.phone,
        ultimaVisita: visitor.lastVisitAt?.toIso8601String() ?? '',
      );
      final map = response['data'] as Map<String, dynamic>;
      return Visitor(
        id: map['id']?.toString() ?? visitor.id,
        name: map['nombre']?.toString() ?? visitor.name,
        phone: map['telefono'] ?? visitor.phone,
        visitCount: map['cantidad_visitas'] as int? ?? visitor.visitCount,
        lastVisitAt: map['ultima_visita'] != null
            ? DateTime.tryParse(map['ultima_visita'].toString())
            : visitor.lastVisitAt,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Visitor>> getVisitantesVivienda({required int personaId}) async {
    try {
      final response =
          await api.getVisitantesVivienda(personaId: personaId);
      final visitantes = response['visitantes'] as List<dynamic>? ?? [];
      return visitantes.map((item) {
        final map = item as Map<String, dynamic>;
        return Visitor(
          id: map['identificacion']?.toString() ?? '',
          name: '${map['nombres'] ?? ''} ${map['apellidos'] ?? ''}'.trim(),
          phone: null,
          visitCount: 0,
          lastVisitAt: map['fecha_creado'] != null
              ? DateTime.tryParse(map['fecha_creado'].toString())
              : null,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
