import '../ports/qr_repository.dart';
import '../entities/qr_code.dart';

class GenerateQrUseCase {
  final QrRepository repo;
  GenerateQrUseCase(this.repo);

  Future<QrCode> self({required String accountId, required DateTime expiresAt, int? maxUses}) {
    return repo.generateSelf(accountId: accountId, expiresAt: expiresAt, maxUses: maxUses);
  }

  Future<QrCode> visit({
    required String accountId,
    required String visitorId,
    required String visitorName,
    required DateTime expiresAt,
    int? maxUses,
  }) {
    return repo.generateVisit(
      accountId: accountId,
      visitorId: visitorId,
      visitorName: visitorName,
      expiresAt: expiresAt,
      maxUses: maxUses,
    );
  }
}
