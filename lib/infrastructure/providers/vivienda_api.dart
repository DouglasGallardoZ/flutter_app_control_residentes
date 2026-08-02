import 'package:dio/dio.dart';

class ViviendaApi {
  final Dio dio;

  ViviendaApi(this.dio);

  Future<Map<String, dynamic>> listar({
    int page = 1,
    int pageSize = 20,
    String? manzana,
    String? estado,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (manzana != null && manzana.isNotEmpty) {
        queryParams['manzana'] =
            manzana;
      }
      if (estado != null && estado.isNotEmpty) {
        queryParams['estado'] =
            estado;
      }

      final response = await dio.get(
        '/viviendas',
        queryParameters:
            queryParams,
      );
      return response.data
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
          'Error al listar viviendas: ${e.message}');
    }
  }

  Future<Map<String, dynamic>>
      obtenerPorId(int viviendaId) async {
    try {
      final response = await dio
          .get('/viviendas/$viviendaId/detalle');
      return response.data
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
          'Error al obtener vivienda: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> crear({
    required String manzana,
    required String villa,
  }) async {
    try {
      final response =
          await dio.post(
        '/viviendas',
        data: {
          'manzana': manzana,
          'villa': villa,
          'estado': 'activo',
        },
      );
      return response.data
          as Map<String, dynamic>;
    } on DioException catch (e) {
      final detail = e.response?.data?[
              'detail']
          ?.toString();
      throw Exception(
          detail ?? 'Error al crear vivienda');
    }
  }

  Future<Map<String, dynamic>> actualizar({
    required int viviendaId,
    String? manzana,
    String? villa,
  }) async {
    try {
      final data =
          <String, dynamic>{
        if (manzana != null)
          'manzana': manzana,
        if (villa != null)
          'villa': villa,
      };

      final response =
          await dio.put(
        '/viviendas/$viviendaId',
        data: data,
      );
      return response.data
          as Map<String, dynamic>;
    } on DioException catch (e) {
      final detail = e.response?.data?[
              'detail']
          ?.toString();
      throw Exception(
          detail ?? 'Error al actualizar vivienda');
    }
  }

  Future<void> cambiarEstado({
    required int viviendaId,
    required String estado,
    String? motivo,
  }) async {
    try {
      await dio.put(
        '/viviendas/$viviendaId/estado',
        data: {
          'estado': estado,
          if (motivo != null)
            'motivo': motivo,
        },
      );
    } on DioException catch (e) {
      final detail = e.response?.data?[
              'detail']
          ?.toString();
      throw Exception(
          detail ?? 'Error al cambiar estado');
    }
  }

  Future<Map<String, dynamic>> getVillaDetalle(int viviendaId) async {
    try {
      final response = await dio.get('/viviendas/$viviendaId/detalle');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final detail = e.response?.data?['detail']?.toString();
      throw Exception(detail ?? 'Error al obtener detalle de villa');
    }
  }

  Future<void> cambiarPropietario({
    required int viviendaId,
    required int nuevoPropietarioId,
    required String tipo,
    required String motivo,
  }) async {
    try {
      await dio.post(
        '/viviendas/cambio-propietario',
        data: {
          'vivienda_id': viviendaId,
          'nuevo_propietario_id': nuevoPropietarioId,
          'tipo': tipo,
          'motivo': motivo,
        },
      );
    } on DioException catch (e) {
      final detail = e.response?.data?['detail']?.toString();
      throw Exception(detail ?? 'Error al cambiar propietario');
    }
  }

  Future<Map<String, dynamic>?> buscarPersonaPorCedula(
      String cedula) async {
    try {
      final response = await dio.get('/personas/buscar/$cedula');
      final data = response.data;
      if (data is Map && data['encontrada'] == true) {
        return data['persona'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      final detail = e.response?.data?['detail']?.toString();
      throw Exception(detail ?? 'Error al buscar persona');
    }
  }
}
