import '../entities/access_log.dart';

abstract class AccessHistoryRepository {
  Future<List<AccessLog>> loadAccessLogs({
    int page = 1,
    int pageSize = 20,
  });
}
