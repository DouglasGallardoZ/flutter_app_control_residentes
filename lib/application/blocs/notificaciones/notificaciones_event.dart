part of 'notificaciones_bloc.dart';

abstract class NotificacionesEvent {}

class NotificacionesIniciadas extends NotificacionesEvent {
  final String usuarioId;
  NotificacionesIniciadas(this.usuarioId);
}

class NotificacionesRefrescadas extends NotificacionesEvent {}

class NotificacionMarcadaLeida extends NotificacionesEvent {
  final int notificacionId;
  NotificacionMarcadaLeida(this.notificacionId);
}

class TodasNotificacionesMarcadasLeidas
    extends NotificacionesEvent {}

class NotificacionEliminada extends NotificacionesEvent {
  final int notificacionId;
  NotificacionEliminada(this.notificacionId);
}
