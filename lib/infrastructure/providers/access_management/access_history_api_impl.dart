import 'package:dio/dio.dart';
import '../../../domain/ports/access_management/access_history_api_port.dart';
import '../../../core/api_error_handler.dart';

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
      throw Exception(ApiErrorHandler.manejar(e));
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


}
