// lib/infrastructure/providers/access_history_api.dart
import 'package:dio/dio.dart';

class AccessHistoryApi {
  final Dio dio;

  AccessHistoryApi(this.dio);

  /// Obtener historial de acceso
  Future<Map<String, dynamic>> obtenerHistorial({
    int page = 1,
    int pageSize = 10,
    String? filtro, // opcional: por tipo de acceso o fecha
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (filtro != null) 'filtro': filtro,
      };
      final response = await dio.get(
        '/accesos/historial',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalles de un acceso específico
  Future<Map<String, dynamic>> obtenerAcceso(int accesoId) async {
    try {
      final response = await dio.get('/accesos/$accesoId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Validar QR de acceso
  Future<Map<String, dynamic>> validarQR({
    required String qrToken,
    String? metodoBiometrico, // facial, huella
  }) async {
    try {
      final response = await dio.post('/accesos/validar-qr', data: {
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
