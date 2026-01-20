abstract class QrEvent {}

class GenerateSelfQrConfigured extends QrEvent {
  final int personaId;
  final DateTime validFrom;
  final int durationHours;
  final int? maxUses;
  GenerateSelfQrConfigured(this.personaId, this.validFrom, this.durationHours, {this.maxUses});
}

/// Almacenar contexto de navegación actual para QrDisplayPage
class SaveQrNavigationContext extends QrEvent {
  final int personaId;
  final String identificacion;
  final String residenceId;
  final String userName;
  final String qrValue;
  final DateTime validFrom;
  final DateTime validUntil;
  final int durationHours;
  final String? visitName;
  final String? visitIdentificacion;

  SaveQrNavigationContext({
    required this.personaId,
    required this.identificacion,
    required this.residenceId,
    required this.userName,
    required this.qrValue,
    required this.validFrom,
    required this.validUntil,
    required this.durationHours,
    this.visitName,
    this.visitIdentificacion,
  });
}

class ClearQrNavigationContext extends QrEvent {}
