import 'package:dio/dio.dart';
import '../../domain/entities/qr_list_response.dart';

class QrListApi {
  final Dio dio;

  QrListApi(this.dio);

  Future<QrListResponse> listarQRsGenerados({
    required int page,
    required int pageSize,
    required String tipoIngreso, // all, propio, visita
    required String usuarioId,
  }) async {
    final queryParams = {
      'persona_id': usuarioId,
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'tipo_ingreso': tipoIngreso,
    };

    try {
      final response = await dio.get(
        '/qr/cuenta/generados',
        queryParameters: queryParams,
      );

      return QrListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(
        'Error al obtener QRs generados: ${e.message}',
      );
    } catch (e) {
      throw Exception('Error al conectar con el API: $e');
    }
  }

  Future<void> anularQr(int qrId) async {
    try {
      await dio.put('/qr/$qrId/anular');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Error al anular el QR',
      );
    }
  }
}
