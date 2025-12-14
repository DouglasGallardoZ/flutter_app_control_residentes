abstract class QrEvent {}
class GenerateSelfQr extends QrEvent {
  final String accountId;
  final DateTime expiresAt;
  final int? maxUses;
  GenerateSelfQr(this.accountId, this.expiresAt, {this.maxUses});
}
class GenerateVisitQr extends QrEvent {
  final String accountId;
  final String visitorId;
  final String visitorName;
  final DateTime expiresAt;
  final int? maxUses;
  GenerateVisitQr(this.accountId, this.visitorId, this.visitorName, this.expiresAt, {this.maxUses});
}
