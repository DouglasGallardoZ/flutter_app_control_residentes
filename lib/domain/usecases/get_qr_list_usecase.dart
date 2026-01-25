import '../../domain/entities/qr_list_response.dart';
import '../../infrastructure/providers/qr_list_api.dart';

abstract class GetQrListUseCase {
  Future<QrListResponse> call({
    required int page,
    required int pageSize,
    required String tipoIngreso,
    required String usuarioId,
  });
}

class GetQrListUseCaseImpl implements GetQrListUseCase {
  final QrListApi qrListApi;

  GetQrListUseCaseImpl({required this.qrListApi});

  @override
  Future<QrListResponse> call({
    required int page,
    required int pageSize,
    required String tipoIngreso,
    required String usuarioId,
  }) async {
    return await qrListApi.listarQRsGenerados(
      page: page,
      pageSize: pageSize,
      tipoIngreso: tipoIngreso,
      usuarioId: usuarioId,
    );
  }
}
