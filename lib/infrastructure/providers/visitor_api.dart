import 'package:dio/dio.dart';

class VisitorApi {
  final Dio dio;

  VisitorApi(this.dio);

  /// Listar visitantes por residencia
  Future<Map<String, dynamic>> listByResidence({
    required int personaId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await dio.get(
        '/miembros/visitantes',
        queryParameters: {
          'usuario_id': personaId,
          'page': page,
          'page_size': pageSize,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener visitante por ID
  Future<Map<String, dynamic>> findById({
    required int personaId,
    required String visitantId,
  }) async {
    try {
      final response = await dio.get(
        '/miembros/visitantes/$visitantId',
        queryParameters: {
          'usuario_id': personaId,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Crear o actualizar visitante
  Future<Map<String, dynamic>> upsert({
    required int personaId,
    required String id,
    required String nombre,
    String? telefono,
    required String ultimaVisita,
  }) async {
    try {
      final response = await dio.post(
        '/miembros/visitantes',
        queryParameters: {
          'usuario_id': personaId,
        },
        data: {
          'id': id,
          'nombre': nombre,
          'telefono': telefono,
          'ultima_visita': ultimaVisita,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
