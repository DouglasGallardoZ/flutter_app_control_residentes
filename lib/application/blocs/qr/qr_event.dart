abstract class QrEvent {}

class GenerateSelfQrConfigured extends QrEvent {
  final String accountId;
  final DateTime validFrom;
  final int durationHours;
  final int? maxUses;
  GenerateSelfQrConfigured(this.accountId, this.validFrom, this.durationHours, {this.maxUses});
}
