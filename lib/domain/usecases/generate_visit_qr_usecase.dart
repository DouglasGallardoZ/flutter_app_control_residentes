import '../ports/qr_repository.dart';
import '../entities/qr_code.dart';

class GenerateVisitQrUseCase {
  final QrRepository repo;
  GenerateVisitQrUseCase(this.repo);

  Future<QrCode> call({
    required int personaId,
    required String visitorId,
    required String visitorName,
    required DateTime validFrom,
    required int durationHours,
    int? maxUses,
  }) {
    return repo.generateVisit(
      personaId: personaId,
      visitorId: visitorId,
      visitorName: visitorName,
      validFrom: validFrom,
      durationHours: durationHours,
      maxUses: maxUses,
    );
  }
}
