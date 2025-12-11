import '../entities/qr_code.dart';
import '../entities/visitor.dart';

abstract class QrRepository {
  Future<QrCode> generateSelf({required String accountId, required Map<String, dynamic> params});
  Future<QrCode> generateVisit({
    required String accountId,
    required Visitor visitor,
    required Map<String, dynamic> params,
  });
}
