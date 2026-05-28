import '../../domain/entities/qr_list_response.dart';
import '../../domain/ports/qr_management/qr_query_api_port.dart';

abstract class GetQrListUseCase {
  Future<QrListResponse> call({
    required int page,
    required int pageSize,
    required String tipoIngreso,
    required String usuarioId,
  });
}

class GetQrListUseCaseImpl implements GetQrListUseCase {
  final QrQueryApiPort qrQueryApi;

  GetQrListUseCaseImpl({required this.qrQueryApi});

  @override
  Future<QrListResponse> call({
    required int page,
    required int pageSize,
    required String tipoIngreso,
    required String usuarioId,
  }) async {
    final data = await qrQueryApi.listarQRs(
      page: page,
      pageSize: pageSize,
      tipoIngreso: tipoIngreso,
      usuarioId: usuarioId,
    );
    return QrListResponse.fromJson(data);
  }
}
