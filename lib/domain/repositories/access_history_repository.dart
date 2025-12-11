import '../entities/access_log.dart';

abstract class AccessHistoryRepository {
  Future<List<AccessLog>> loadAccessLogs({required String accountId});
}
