part of 'aprobacion_miembro_bloc.dart';

sealed class AprobacionMiembroState
    extends Equatable {
  const AprobacionMiembroState();
  @override
  List<Object?> get props => [];
}

class AprobacionMiembroInicial
    extends AprobacionMiembroState {}

class AprobacionMiembroCargando
    extends AprobacionMiembroState {}

class AprobacionMiembroVacio
    extends AprobacionMiembroState {}

class SolicitudesPendientesCargadas
    extends AprobacionMiembroState {
  final List<SolicitudMiembro> solicitudes;
  const SolicitudesPendientesCargadas(
      {required this.solicitudes});
  @override
  List<Object?> get props => [solicitudes];
}

class AprobacionMiembroProcesando
    extends AprobacionMiembroState {
  final String mensaje;
  const AprobacionMiembroProcesando(
      {required this.mensaje});
  @override
  List<Object?> get props => [mensaje];
}

class SolicitudAprobadaExitosa
    extends AprobacionMiembroState {
  final int personaId;
  final int miembroId;
  final String mensaje;
  const SolicitudAprobadaExitosa({
    required this.personaId,
    required this.miembroId,
    required this.mensaje,
  });
  @override
  List<Object?> get props =>
      [personaId, miembroId, mensaje];
}

class SolicitudRechazadaExitosa
    extends AprobacionMiembroState {
  final String mensaje;
  const SolicitudRechazadaExitosa(
      {required this.mensaje});
  @override
  List<Object?> get props => [mensaje];
}

class AprobacionMiembroError
    extends AprobacionMiembroState {
  final String mensaje;
  const AprobacionMiembroError(
      {required this.mensaje});
  @override
  List<Object?> get props => [mensaje];
}
