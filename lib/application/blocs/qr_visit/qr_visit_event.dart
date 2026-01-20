abstract class QrVisitEvent {}
class GenerateVisitQrRequested extends QrVisitEvent {
  final int personaId;
  final String visitorId;
  final String visitorName;
  final DateTime validFrom;
  final int durationHours;
  GenerateVisitQrRequested(this.personaId, this.visitorId, this.visitorName, this.validFrom, this.durationHours);
}
