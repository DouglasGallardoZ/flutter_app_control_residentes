import '../entities/qr_code.dart';
import '../entities/visitor.dart';

abstract class QrRepository {
  Future<QrCode> generateSelf({required String accountId, required DateTime expiresAt, int? maxUses});
  Future<QrCode> generateVisit({
    required String accountId,
    required String visitorId,
    required String visitorName,
    required DateTime expiresAt,
    int? maxUses,
  });
}
