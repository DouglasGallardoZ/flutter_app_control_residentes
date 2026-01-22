import 'package:equatable/equatable.dart';

abstract class FacialEnrollmentEvent extends Equatable {
  const FacialEnrollmentEvent();

  @override
  List<Object?> get props => [];
}

/// Inicia el proceso de registro facial
class InitiateFacialEnrollment extends FacialEnrollmentEvent {
  final String personaId;

  const InitiateFacialEnrollment({required this.personaId});

  @override
  List<Object?> get props => [personaId];
}

/// Se detectó un rostro en la cámara
class FaceDetected extends FacialEnrollmentEvent {
  final double eulerAngleY; // Ángulo de rotación de cabeza
  final String imagePath; // Ruta de la imagen capturada

  const FaceDetected({
    required this.eulerAngleY,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [eulerAngleY, imagePath];
}

/// Enviar datos de biometría al servidor
class SubmitFacialEnrollment extends FacialEnrollmentEvent {
  final List<String> imagenesRutas; // 3 rutas de imágenes

  const SubmitFacialEnrollment({required this.imagenesRutas});

  @override
  List<Object?> get props => [imagenesRutas];
}

/// Reintentar captura
class RetryFacialEnrollment extends FacialEnrollmentEvent {
  const RetryFacialEnrollment();
}
