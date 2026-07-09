part of 'autorizacion_miembro_bloc.dart';

abstract class AutorizacionMiembroState {}

class AutorizacionMiembroInicial
    extends AutorizacionMiembroState {}

class SolicitudEnviando
    extends AutorizacionMiembroState {}

class EsperandoAutorizacion
    extends AutorizacionMiembroState {
  final String mensaje;
  final int notificacionId;

  EsperandoAutorizacion({
    required this.mensaje,
    required this.notificacionId,
  });
}

class AutorizacionAprobada
    extends AutorizacionMiembroState {
  final int personaId;
  final int? miembroId;

  AutorizacionAprobada({
    required this.personaId,
    this.miembroId,
  });
}

class AutorizacionRechazada
    extends AutorizacionMiembroState {
  final String? motivo;

  AutorizacionRechazada({this.motivo});
}

class AutorizacionMiembroError
    extends AutorizacionMiembroState {
  final String mensaje;

  AutorizacionMiembroError(this.mensaje);
}
