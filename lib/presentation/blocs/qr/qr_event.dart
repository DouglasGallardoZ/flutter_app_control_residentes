abstract class QrEvent {}

class GenerateSelfQr extends QrEvent {
  final String accountId;
  final Map<String, dynamic> params;
  GenerateSelfQr(this.accountId, this.params);
}

class GenerateVisitQr extends QrEvent {
  final String accountId;
  final Map<String, dynamic> params;
  final String visitorName;
  final String visitorId;
  GenerateVisitQr(this.accountId, this.params, this.visitorName, this.visitorId);
}
