import '../ports/access_history_repository.dart';
import '../entities/access_log.dart';

class LoadAccessHistoryUseCase {
  final AccessHistoryRepository repo;
  LoadAccessHistoryUseCase(this.repo);

  Future<List<AccessLog>> call(String accountId) => repo.loadAccessLogs(accountId: accountId);
}
