import '../ports/qr_repository.dart';
import '../entities/qr_code.dart';

class GenerateQrUseCase {
  final QrRepository repo;
  GenerateQrUseCase(this.repo);

  Future<QrCode> self({
    required int personaId,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  }) {
    return repo.generateSelf(
      personaId: personaId,
      validFrom: validFrom,
      durationHours: durationHours,
      maxUses: maxUses,
    );
  }

  // Future<QrCode> visit({
  //   required int personaId,
  //   required String visitorId,
  //   required String visitorName,
  //   required DateTime expiresAt,
  //   int? maxUses,
  // }) {
  //   return repo.generateVisit(
  //     personaId: personaId,
  //     visitorId: visitorId,
  //     visitorName: visitorName,
  //     expiresAt: expiresAt,
  //     maxUses: maxUses,
  //   );
  // }
}
