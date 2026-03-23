import 'package:dio/dio.dart';
import '../../../domain/ports/access_management/access_history_api_port.dart';

class AccessHistoryApiImpl implements AccessHistoryApiPort {
  final Dio dio;

  AccessHistoryApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getResidenceAccesses({
    required int viviendaId,
    String? fechaInicio,
    String? fechaFin,
    String? tipo,
    String? resultado,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fechaInicio != null) queryParams['fecha_inicio'] = fechaInicio;
      if (fechaFin != null) queryParams['fecha_fin'] = fechaFin;
      if (tipo != null) queryParams['tipo'] = tipo;
      if (resultado != null) queryParams['resultado'] = resultado;

      final response = await dio.get(
        '/accesos/vivienda/$viviendaId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> obtenerHistorial({
    int page = 1,
    int pageSize = 10,
    String? filtro,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (filtro != null) 'filtro': filtro,
      };
      final response = await dio.get(
        '/acceso/historial',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> obtenerAcceso(int accesoId) async {
    try {
      final response = await dio.get('/acceso/$accesoId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> validarQR({
    required String qrToken,
    String? metodoBiometrico,
  }) async {
    try {
      final response = await dio.post('/acceso/validar-qr', data: {
        'qr_token': qrToken,
        if (metodoBiometrico != null) 'metodo_biometrico': metodoBiometrico,
        'usuario_creado': 'flutter_app',
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Método auxiliar para extraer errores detallados de la respuesta API
  String _extractErrorMessage(dynamic error) {
    if (error is DioException && error.response != null) {
      final data = error.response?.data;
      if (data is Map) {
        // Intenta extraer el field 'detail' primero
        if (data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) return detail;
          if (detail is List && detail.isNotEmpty) {
            final firstItem = detail.first;
            if (firstItem is Map && firstItem.containsKey('msg')) {
              return firstItem['msg'];
            }
          }
        }
        // Si hay 'message', usa eso
        if (data.containsKey('message')) {
          return data['message'] ?? 'Error desconocido';
        }
      }
      return error.message ?? 'Error en la solicitud';
    }
    return error.toString();
  }
}
