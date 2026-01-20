import '../../domain/ports/access_history_repository.dart';
import '../../domain/entities/access_log.dart';
import '../providers/access_history_api.dart';

class AccessHistoryRepositoryImpl implements AccessHistoryRepository {
  final AccessHistoryApi accessHistoryApi;

  AccessHistoryRepositoryImpl(this.accessHistoryApi);

  @override
  Future<List<AccessLog>> loadAccessLogs({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await accessHistoryApi.obtenerHistorial(
        page: page,
        pageSize: pageSize,
      );

      final data = response['data'] as List? ?? [];
      return data.map((item) {
        return AccessLog(
          personId: item['persona_id'] ?? 0,
          personName: '${item['nombres'] ?? ''} ${item['apellidos'] ?? ''}',
          roleLabel: item['rol'] ?? 'residente',
          timestamp: item['fecha_acceso'] is String
              ? DateTime.parse(item['fecha_acceso'])
              : DateTime.now(),
          success: item['estado'] == 'permitido' || item['estado'] == 'exitoso',
          reason: item['motivo'],
          referencedBy: item['tipo_qr'],
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
