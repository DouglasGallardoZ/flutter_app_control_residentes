part of 'aprobacion_miembro_bloc.dart';

sealed class AprobacionMiembroEvent
    extends Equatable {
  const AprobacionMiembroEvent();
  @override
  List<Object?> get props => [];
}

class CargarSolicitudesPendientes
    extends AprobacionMiembroEvent {}

class RecargarSolicitudes
    extends AprobacionMiembroEvent {}

class AprobarSolicitud
    extends AprobacionMiembroEvent {
  final int solicitudId;
  const AprobarSolicitud(this.solicitudId);
  @override
  List<Object?> get props => [solicitudId];
}

class RechazarSolicitud
    extends AprobacionMiembroEvent {
  final int solicitudId;
  final String? motivo;
  const RechazarSolicitud(this.solicitudId,
      {this.motivo});
  @override
  List<Object?> get props => [solicitudId, motivo];
}
