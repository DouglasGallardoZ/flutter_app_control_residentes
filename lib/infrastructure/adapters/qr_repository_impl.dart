import 'dart:math';
import '../../domain/entities/qr_code.dart';
import '../../domain/ports/qr_repository.dart';
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
  Future<QrCode> generateSelf({
    required String accountId,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  }) async {
    final now = DateTime.now();
    final expiresAt = validFrom.add(Duration(hours: durationHours));
    final value = 'SELF-$accountId-${_randomCode()}';
    final qr = QrCode(
      value: value,
      createdAt: now,
      validFrom: validFrom,
      expiresAt: expiresAt,
      durationHours: durationHours,
      maxUses: maxUses,
      type: 'self',
    );
    await store.db.collection('qr_codes').add({
      'accountId': accountId,
      'value': qr.value,
      'type': qr.type,
      'createdAt': qr.createdAt.toIso8601String(),
      'validFrom': qr.validFrom.toIso8601String(),
      'expiresAt': qr.expiresAt.toIso8601String(),
      'durationHours': qr.durationHours,
      'maxUses': qr.maxUses,
    });
    return qr;
  }

  // lib/infrastructure/adapters/qr_repository_impl.dart
  // Actualiza generateVisit para aceptar validFrom + durationHours
  @override
  Future<QrCode> generateVisit({
    required String accountId,
    required String visitorId,
    required String visitorName,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  }) async {
    final now = DateTime.now();
    final expiresAt = validFrom.add(Duration(hours: durationHours));
    final value = 'VISIT-$accountId-$visitorId-${_randomCode()}';
    final qr = QrCode(
      value: value, createdAt: now, validFrom: validFrom, expiresAt: expiresAt,
      durationHours: durationHours, maxUses: maxUses, type: 'visit',
    );
    await store.db.collection('qr_codes').add({
      'accountId': accountId,
      'visitor': {'id': visitorId, 'name': visitorName},
      'value': qr.value,
      'type': qr.type,
      'createdAt': qr.createdAt.toIso8601String(),
      'validFrom': qr.validFrom.toIso8601String(),
      'expiresAt': qr.expiresAt.toIso8601String(),
      'durationHours': qr.durationHours,
      'maxUses': qr.maxUses,
    });
    return qr;
  }

}
