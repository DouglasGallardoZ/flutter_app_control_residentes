import '../entities/qr_code.dart';

abstract class QrRepository {
  Future<QrCode> generateVisit({
    required int personaId,
    required String visitorId,
    required String visitorName,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  });

  Future<QrCode> generateSelf({
    required int personaId,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  });
}
