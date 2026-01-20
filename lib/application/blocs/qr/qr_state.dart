import '../../../domain/entities/qr_code.dart';

abstract class QrState {}

class QrInitial extends QrState {}

class QrLoading extends QrState {}

class QrReady extends QrState {
  final QrCode qr;
  QrReady(this.qr);
}

class QrError extends QrState {
  final String message;
  QrError(this.message);
}

/// Estado que mantiene el contexto de navegación actual
class QrNavigationContextReady extends QrState {
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

  QrNavigationContextReady({
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
