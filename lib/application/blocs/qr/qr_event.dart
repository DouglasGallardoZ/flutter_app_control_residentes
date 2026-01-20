abstract class QrEvent {}

class GenerateSelfQrConfigured extends QrEvent {
  final int personaId;
  final DateTime validFrom;
  final int durationHours;
  final int? maxUses;
  GenerateSelfQrConfigured(this.personaId, this.validFrom, this.durationHours, {this.maxUses});
}
