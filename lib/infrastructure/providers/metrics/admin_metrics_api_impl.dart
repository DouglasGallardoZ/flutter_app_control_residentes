import 'package:dio/dio.dart';
import '../../../domain/ports/metrics/admin_metrics_api_port.dart';

class AdminMetricsApiImpl implements AdminMetricsApiPort {
  final Dio dio;

  AdminMetricsApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getAdminMetrics({
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (fechaInicio != null) queryParams['fecha_inicio'] = fechaInicio;
      if (fechaFin != null) queryParams['fecha_fin'] = fechaFin;

      final response = await dio.get(
        '/accesos/admin/estadisticas',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      // Transformar respuesta del API a formato compatible con el resto de la app
      return _transformAccessStatsToMetrics(response.data ?? {});
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> getAccessHistory({
    int page = 1,
    int pageSize = 50,
    String? fechaInicio,
    String? fechaFin,
    String? tipo,
    String? resultado,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (fechaInicio != null) queryParams['fecha_inicio'] = fechaInicio;
      if (fechaFin != null) queryParams['fecha_fin'] = fechaFin;
      if (tipo != null) queryParams['tipo'] = tipo;
      if (resultado != null) queryParams['resultado'] = resultado;

      final response = await dio.get(
        '/accesos/admin/historial',
        queryParameters: queryParams,
      );

      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Transforma estadísticas de accesos a formato de métricas del dashboard
  Map<String, dynamic> _transformAccessStatsToMetrics(
      Map<String, dynamic> stats) {
    final estadisticasGenerales =
        stats['estadisticas_generales'] as Map<String, dynamic>? ?? {};

    return {
      'total_access': estadisticasGenerales['total'] ?? 0,
      'successful_access': estadisticasGenerales['exitosos'] ?? 0,
      'denied_access': estadisticasGenerales['rechazados'] ?? 0,
      'visitors': stats['cantidad_visitantes_unicos'] ?? 0,
      'recent_activity': _generateRecentActivityFromStats(stats),
    };
  }

  /// Genera lista de actividad reciente a partir de estadísticas
  List<Map<String, dynamic>> _generateRecentActivityFromStats(
      Map<String, dynamic> stats) {
    final viviendas =
        (stats['viviendas_con_mas_accesos'] as List<dynamic>?) ?? [];

    // Convertir top viviendas a actividad reciente (mostrar las viviendas con más accesos)
    return viviendas.map((vivienda) {
      final v = vivienda as Map<String, dynamic>;
      return {
        'person_name': 'Vivienda ${v['manzana']}-${v['villa']}',
        'person_role': 'location',
        'access_type': 'summary',
        'related_person': '',
        'timestamp': DateTime.now().toIso8601String(),
        'entry_point': 'Residencial',
        'status': 'success',
        'cantidad_accesos': v['cantidad_accesos'] ?? 0,
      };
    }).toList();
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
