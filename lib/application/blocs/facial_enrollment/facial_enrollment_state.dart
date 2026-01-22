import 'package:equatable/equatable.dart';

abstract class FacialEnrollmentState extends Equatable {
  const FacialEnrollmentState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class FacialEnrollmentInitial extends FacialEnrollmentState {
  const FacialEnrollmentInitial();
}

/// En progreso - esperando captura de rostros
class FacialEnrollmentInProgress extends FacialEnrollmentState {
  final int fotosCapturadas; // 0, 1, 2
  final String instruccion; // "MIRE AL FRENTE", "GIRE A LA IZQUIERDA", "GIRE A LA DERECHA"
  final String fase; // "FRENTE", "IZQUIERDA", "DERECHA"

  const FacialEnrollmentInProgress({
    required this.fotosCapturadas,
    required this.instruccion,
    required this.fase,
  });

  @override
  List<Object?> get props => [fotosCapturadas, instruccion, fase];
}

/// Se capturó una foto correctamente
class FacialPhotoCaptured extends FacialEnrollmentState {
  final int fotoNumero; // 1, 2, 3
  final String rutaImagen;

  const FacialPhotoCaptured({
    required this.fotoNumero,
    required this.rutaImagen,
  });

  @override
  List<Object?> get props => [fotoNumero, rutaImagen];
}

/// Enviando datos al servidor
class FacialEnrollmentSubmitting extends FacialEnrollmentState {
  const FacialEnrollmentSubmitting();
}

/// Registro facial exitoso
class FacialEnrollmentSuccess extends FacialEnrollmentState {
  final String mensaje;
  final String? enrollmentId;

  const FacialEnrollmentSuccess({
    required this.mensaje,
    this.enrollmentId,
  });

  @override
  List<Object?> get props => [mensaje, enrollmentId];
}

/// Error en el registro facial
class FacialEnrollmentError extends FacialEnrollmentState {
  final String mensaje;

  const FacialEnrollmentError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

/// Esperando entrada del usuario (sin rostro detectado)
class FacialEnrollmentWaiting extends FacialEnrollmentState {
  final String mensaje;

  const FacialEnrollmentWaiting({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
