abstract class QrVisitEvent {}
class GenerateVisitQrRequested extends QrVisitEvent {
  final String accountId;
  final String visitorId;
  final String visitorName;
  final DateTime validFrom;
  final int durationHours;
  GenerateVisitQrRequested(this.accountId, this.visitorId, this.visitorName, this.validFrom, this.durationHours);
}
