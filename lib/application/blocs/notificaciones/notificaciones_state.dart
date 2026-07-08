part of 'notificaciones_bloc.dart';

abstract class NotificacionesState {}

class NotificacionesCargando extends NotificacionesState {}

class NotificacionesCargadas extends NotificacionesState {
  final List<NotificacionItem> notificaciones;
  final int noLeidas;

  NotificacionesCargadas({
    required this.notificaciones,
    required this.noLeidas,
  });
}

class NotificacionesVacias extends NotificacionesState {}

class NotificacionesError extends NotificacionesState {
  final String mensaje;
  NotificacionesError(this.mensaje);
}

class NotificacionesOperacionExitosa
    extends NotificacionesState {
  final String mensaje;
  NotificacionesOperacionExitosa(this.mensaje);
}
