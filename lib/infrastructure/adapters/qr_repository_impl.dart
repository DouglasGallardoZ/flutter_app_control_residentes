import 'dart:math';
import '../../domain/ports/qr_repository.dart';
import '../../domain/entities/qr_code.dart';
import '../providers/firestore_provider.dart';

class QrRepositoryImpl implements QrRepository {
  final FirestoreProvider store;
  QrRepositoryImpl(this.store);

  String _randomCode() {
    final rng = Random.secure();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(10, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  @override
  Future<QrCode> generateSelf({required String accountId, required DateTime expiresAt, int? maxUses}) async {
    final value = 'SELF-$accountId-${_randomCode()}';
    final now = DateTime.now();
    final qr = QrCode(value: value, createdAt: now, expiresAt: expiresAt, maxUses: maxUses, type: 'self');
    await store.db.collection('qr_codes').add({
      'accountId': accountId,
      'value': qr.value,
      'type': qr.type,
      'createdAt': qr.createdAt.toIso8601String(),
      'expiresAt': qr.expiresAt?.toIso8601String(),
      'maxUses': qr.maxUses,
    });
    return qr;
  }

  @override
  Future<QrCode> generateVisit({
    required String accountId,
    required String visitorId,
    required String visitorName,
    required DateTime expiresAt,
    int? maxUses,
  }) async {
    final value = 'VISIT-$accountId-$visitorId-${_randomCode()}';
    final now = DateTime.now();
    final qr = QrCode(value: value, createdAt: now, expiresAt: expiresAt, maxUses: maxUses, type: 'visit');
    await store.db.collection('qr_codes').add({
      'accountId': accountId,
      'visitor': {'id': visitorId, 'name': visitorName},
      'value': qr.value,
      'type': qr.type,
      'createdAt': qr.createdAt.toIso8601String(),
      'expiresAt': qr.expiresAt?.toIso8601String(),
      'maxUses': qr.maxUses,
    });
    return qr;
  }
}
