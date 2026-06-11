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
