import '../../domain/entities/access_log.dart';
import '../../domain/repositories/access_history_repository.dart';
import '../providers/firestore_provider.dart';

class AccessHistoryRepositoryImpl implements AccessHistoryRepository {
  final FirestoreProvider db;
  AccessHistoryRepositoryImpl({required this.db});

  @override
  Future<List<AccessLog>> loadAccessLogs({required String accountId}) async {
    final snap = await db.db
        .collection('access_logs')
        .where('accountId', isEqualTo: accountId)
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((d) => AccessLog.fromMap(d.data())).toList();
  }
}
