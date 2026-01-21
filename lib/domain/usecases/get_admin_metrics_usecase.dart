import '../entities/admin_metrics.dart';
import '../ports/admin_repository.dart';

class GetAdminMetricsUseCase {
  final AdminRepository adminRepository;

  GetAdminMetricsUseCase(this.adminRepository);

  Future<AdminMetrics> call() async {
    return await adminRepository.getAdminMetrics();
  }
}
