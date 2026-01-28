import '../ports/admin_repository.dart';

class GetAccessHistoryUseCase {
  final AdminRepository adminRepository;

  GetAccessHistoryUseCase(this.adminRepository);

  Future<Map<String, dynamic>> call({
    int page = 1,
    int pageSize = 50,
    String? fechaInicio,
    String? fechaFin,
    String? tipo,
    String? resultado,
  }) async {
    return await adminRepository.getAccessHistory(
      page: page,
      pageSize: pageSize,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      tipo: tipo,
      resultado: resultado,
    );
  }
}
