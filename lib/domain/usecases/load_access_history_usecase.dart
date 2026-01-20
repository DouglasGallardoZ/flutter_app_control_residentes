import '../ports/access_history_repository.dart';
import '../entities/access_log.dart';

class LoadAccessHistoryUseCase {
  final AccessHistoryRepository repo;

  LoadAccessHistoryUseCase(this.repo);

  Future<List<AccessLog>> call({
    int page = 1,
    int pageSize = 20,
  }) {
    return repo.loadAccessLogs(
      page: page,
      pageSize: pageSize,
    );
  }
}
