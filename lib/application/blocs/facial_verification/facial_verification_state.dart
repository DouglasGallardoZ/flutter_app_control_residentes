import '../../../domain/entities/liveness_reto.dart';

abstract class FacialVerificationState {}

class FacialVerificationInitial extends FacialVerificationState {}

class FacialVerificationLoading extends FacialVerificationState {}

class FacialVerificationSuccess extends FacialVerificationState {
  final bool match;
  final double distance;

  FacialVerificationSuccess({required this.match, required this.distance});
}

class FacialVerificationFailure extends FacialVerificationState {
  final String mensaje;

  FacialVerificationFailure({required this.mensaje});
}

class LivenessInicial extends FacialVerificationState {
  LivenessInicial();
}

class LivenessRetoPresentado extends FacialVerificationState {
  final LivenessReto retoActual;
  final int indiceReto;
  final int totalRetos;
  final int segundosRestantes;

  LivenessRetoPresentado({
    required this.retoActual,
    required this.indiceReto,
    required this.totalRetos,
    required this.segundosRestantes,
  });

  String get instruccion {
    switch (retoActual) {
      case LivenessReto.frente:
        return 'MIRE AL FRENTE';
      case LivenessReto.izquierda:
        return 'GIRE A LA IZQUIERDA';
      case LivenessReto.derecha:
        return 'GIRE A LA DERECHA';
      case LivenessReto.sonreir:
        return 'SONRÍA';
    }
  }
}

class LivenessErrorTimeout extends FacialVerificationState {
  final String mensaje;

  LivenessErrorTimeout({required this.mensaje});
}

class LivenessExitoCaptura extends FacialVerificationState {
  LivenessExitoCaptura();
}
