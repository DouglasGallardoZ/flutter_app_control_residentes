part of 'admin_notificaciones_bloc.dart';

abstract class AdminNotificacionesEvent {}

class AdminDestinatariosSolicitados
    extends AdminNotificacionesEvent {
  final String? busqueda;
  AdminDestinatariosSolicitados({this.busqueda});
}

class AdminDestinatarioSeleccionado
    extends AdminNotificacionesEvent {
  final int personaId;
  AdminDestinatarioSeleccionado(this.personaId);
}

class AdminSeleccionarTodos
    extends AdminNotificacionesEvent {}

class AdminDeseleccionarTodos
    extends AdminNotificacionesEvent {}

class AdminNotificacionEnviada
    extends AdminNotificacionesEvent {
  final String titulo;
  final String mensaje;
  final String prioridad;
  final String categoria;
  final bool enviarATodos;

  AdminNotificacionEnviada({
    required this.titulo,
    required this.mensaje,
    required this.prioridad,
    required this.categoria,
    required this.enviarATodos,
  });
}

class AdminFiltroManzanaCambiado
    extends AdminNotificacionesEvent {
  final String? manzana;
  AdminFiltroManzanaCambiado(this.manzana);
}

class AdminFiltroVillaCambiado
    extends AdminNotificacionesEvent {
  final String? villa;
  AdminFiltroVillaCambiado(this.villa);
}
