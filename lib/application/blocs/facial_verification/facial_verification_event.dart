abstract class FacialVerificationEvent {}

class VerifyFaceSubmitted extends FacialVerificationEvent {
  final int personaId;
  final String fotoPath;

  VerifyFaceSubmitted({
    required this.personaId,
    required this.fotoPath,
  });
}
