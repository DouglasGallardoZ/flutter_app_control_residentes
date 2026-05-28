import 'package:dio/dio.dart';
import '../../../domain/ports/qr_management/qr_query_api_port.dart';

class QrQueryApiImpl implements QrQueryApiPort {
  final Dio dio;

  QrQueryApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> obtenerQR(int qrId) async {
    try {
      final response = await dio.get('/qr/$qrId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> listarQRs({
    int page = 1,
    int pageSize = 10,
    String tipoIngreso = 'all',
    required String usuarioId,
  }) async {
    try {
      final response = await dio.get('/qr/cuenta/generados', queryParameters: {
        'persona_id': usuarioId,
        'page': page,
        'page_size': pageSize,
        'tipo_ingreso': tipoIngreso,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
