import 'dart:typed_data';

abstract class FacialVerificationEvent {}

class VerifyFaceSubmitted extends FacialVerificationEvent {
  final int personaId;
  final Uint8List fotoBytes;

  VerifyFaceSubmitted({
    required this.personaId,
    required this.fotoBytes,
  });
}

class IniciarVerificacionLiveness extends FacialVerificationEvent {
  IniciarVerificacionLiveness();
}

class ProcesarFrameCamara extends FacialVerificationEvent {
  final double eulerX;
  final double eulerY;
  final double smilingProb;
  final double leftEyeOpenProb;
  final double rightEyeOpenProb;

  ProcesarFrameCamara({
    required this.eulerX,
    required this.eulerY,
    required this.smilingProb,
    required this.leftEyeOpenProb,
    required this.rightEyeOpenProb,
  });
}

class RetoTiempoExpirado extends FacialVerificationEvent {
  RetoTiempoExpirado();
}
