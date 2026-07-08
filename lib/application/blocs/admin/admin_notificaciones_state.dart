part of 'admin_notificaciones_bloc.dart';

abstract class AdminNotificacionesState {}

class AdminNotificacionesInicial
    extends AdminNotificacionesState {}

class AdminNotificacionesCargando
    extends AdminNotificacionesState {}

class AdminDestinatariosCargados
    extends AdminNotificacionesState {
  final List<Destinatario> destinatarios;
  final int seleccionados;

  AdminDestinatariosCargados({
    required this.destinatarios,
    required this.seleccionados,
  });

  List<int> get destinatariosSeleccionados =>
      destinatarios
          .where((d) => d.seleccionado)
          .map((d) => d.personaId)
          .toList();
}

class AdminNotificacionEnviando
    extends AdminNotificacionesState {}

class AdminNotificacionEnviadaExito
    extends AdminNotificacionesState {
  final int enviados;
  final String mensaje;

  AdminNotificacionEnviadaExito({
    required this.enviados,
    required this.mensaje,
  });
}

class AdminNotificacionesError
    extends AdminNotificacionesState {
  final String mensaje;
  AdminNotificacionesError(this.mensaje);
}
