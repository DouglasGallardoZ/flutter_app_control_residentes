import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'facial_enrollment_event.dart';

abstract class FacialEnrollmentState extends Equatable {
  const FacialEnrollmentState();

  @override
  List<Object?> get props => [];
}

class FacialEnrollmentInitial extends FacialEnrollmentState {
  const FacialEnrollmentInitial();
}

class FacialEnrollmentInProgress extends FacialEnrollmentState {
  final Map<FaceAngle, Uint8List?> imagenes;
  final FaceAngle poseActual;
  final String instruccion;

  const FacialEnrollmentInProgress({
    required this.imagenes,
    required this.poseActual,
    required this.instruccion,
  });

  int get fotosCapturadas =>
      imagenes.values.where((img) => img != null).length;

  static FacialEnrollmentInProgress inicial() {
    return FacialEnrollmentInProgress(
      imagenes: {
        FaceAngle.front: null,
        FaceAngle.left: null,
        FaceAngle.right: null,
      },
      poseActual: FaceAngle.front,
      instruccion: 'MIRE AL FRENTE',
    );
  }

  FacialEnrollmentInProgress conCaptura(
      FaceAngle angulo, Uint8List bytes) {
    final nuevasImagenes = Map<FaceAngle, Uint8List?>.from(imagenes);
    nuevasImagenes[angulo] = bytes;

    final pendientes = FaceAngle.values
        .where((a) => nuevasImagenes[a] == null)
        .toList();

    if (pendientes.isEmpty) {
      return FacialEnrollmentInProgress(
        imagenes: nuevasImagenes,
        poseActual: angulo,
        instruccion: 'Captura completa',
      );
    }

    final siguiente = pendientes.first;
    return FacialEnrollmentInProgress(
      imagenes: nuevasImagenes,
      poseActual: siguiente,
      instruccion: _instruccionPara(siguiente),
    );
  }

  static String _instruccionPara(FaceAngle angulo) {
    switch (angulo) {
      case FaceAngle.front:
        return 'MIRE AL FRENTE';
      case FaceAngle.left:
        return 'GIRE A LA IZQUIERDA';
      case FaceAngle.right:
        return 'GIRE A LA DERECHA';
    }
  }

  List<Uint8List> get rutasBytes =>
      imagenes.values.whereType<Uint8List>().toList();

  bool get completo =>
      imagenes.values.every((img) => img != null);

  @override
  List<Object?> get props => [imagenes, poseActual, instruccion];
}

class FacialPhotoCaptured extends FacialEnrollmentState {
  final int fotoNumero;
  final String rutaImagen;
  final FaceAngle angulo;

  const FacialPhotoCaptured({
    required this.fotoNumero,
    required this.rutaImagen,
    required this.angulo,
  });

  @override
  List<Object?> get props => [fotoNumero, rutaImagen, angulo];
}

class FacialEnrollmentSubmitting extends FacialEnrollmentState {
  const FacialEnrollmentSubmitting();
}

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

class FacialEnrollmentError extends FacialEnrollmentState {
  final String mensaje;

  const FacialEnrollmentError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}

class FacialEnrollmentWaiting extends FacialEnrollmentState {
  final String mensaje;

  const FacialEnrollmentWaiting({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
