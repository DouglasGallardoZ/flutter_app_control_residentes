import '../../domain/ports/access_history_repository.dart';
import '../../domain/entities/access_log.dart';
import '../providers/firestore_provider.dart';

class AccessHistoryRepositoryImpl implements AccessHistoryRepository {
  final FirestoreProvider store;
  AccessHistoryRepositoryImpl(this.store);

  @override
  Future<List<AccessLog>> loadAccessLogs({required String accountId}) async {
    final snap = await store.db
        .collection('access_logs')
        .where('accountId', isEqualTo: accountId)
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((d) {
      final m = d.data();
      return AccessLog(
        personId: m['personId'],
        personName: m['personName'] ?? '',
        roleLabel: m['roleLabel'] ?? 'residente',
        timestamp: DateTime.parse(m['timestamp']),
        success: m['success'] ?? false,
        reason: m['reason'],
        referencedBy: m['referencedBy'],
      );
    }).toList();
  }
}
