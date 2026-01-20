import '../entities/qr_code.dart';

abstract class QrRepository {
  Future<QrCode> generateVisit({
    required String accountId,
    required String visitorId,
    required String visitorName,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  });

  Future<QrCode> generateSelf({
    required String accountId,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  });
}
