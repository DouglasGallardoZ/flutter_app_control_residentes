import '../../domain/entities/qr_code.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/repositories/qr_repository.dart';
import '../providers/firestore_provider.dart';
import 'dart:math';

class QrRepositoryImpl implements QrRepository {
  final FirestoreProvider db;
  QrRepositoryImpl({required this.db});

  String _randomCode() {
    final rng = Random.secure();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(10, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  @override
  Future<QrCode> generateSelf({required String accountId, required Map<String, dynamic> params}) async {
    final value = 'SELF-$accountId-${_randomCode()}';
    final now = DateTime.now();
    final qr = QrCode(
      value: value,
      createdAt: now,
      expiresAt: params['expiresAt'] != null ? DateTime.parse(params['expiresAt']) : null,
      maxUses: params['maxUses'],
      type: 'self',
    );
    await db.db.collection('qr_codes').add({
      'accountId': accountId,
      ...qr.toMap(),
    });
    return qr;
  }

  @override
  Future<QrCode> generateVisit({
    required String accountId,
    required Visitor visitor,
    required Map<String, dynamic> params,
  }) async {
    final value = 'VISIT-$accountId-${visitor.id}-${_randomCode()}';
    final now = DateTime.now();
    final qr = QrCode(
      value: value,
      createdAt: now,
      expiresAt: params['expiresAt'] != null ? DateTime.parse(params['expiresAt']) : null,
      maxUses: params['maxUses'],
      type: 'visit',
    );
    await db.db.collection('qr_codes').add({
      'accountId': accountId,
      'visitor': visitor.toMap(),
      ...qr.toMap(),
    });
    return qr;
  }
}
