import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/estado_solicitud.dart';
import '../../../domain/usecases/solicitar_registro_miembro_usecase.dart';
import '../../../domain/usecases/consultar_estado_solicitud_usecase.dart';

part 'autorizacion_miembro_event.dart';
part 'autorizacion_miembro_state.dart';

class AutorizacionMiembroBloc extends Bloc<
    AutorizacionMiembroEvent,
    AutorizacionMiembroState> {
  final SolicitarRegistroMiembroUseCase
      _solicitarRegistro;
  final ConsultarEstadoSolicitudUseCase
      _consultarEstado;

  Timer? _pollingTimer;
  String? _identificacion;

  AutorizacionMiembroBloc({
    required SolicitarRegistroMiembroUseCase
        solicitarRegistro,
    required ConsultarEstadoSolicitudUseCase
        consultarEstado,
  })  : _solicitarRegistro = solicitarRegistro,
        _consultarEstado = consultarEstado,
        super(AutorizacionMiembroInicial()) {
    on<SolicitudEnviada>(_onSolicitudEnviada);
    on<EstadoSolicitudConsultada>(
        _onConsultarEstado);
    on<SolicitudCancelada>(_onCancelar);
  }

  Future<void> _onSolicitudEnviada(
    SolicitudEnviada event,
    Emitter<AutorizacionMiembroState> emit,
  ) async {
    emit(SolicitudEnviando());

    try {
      _identificacion = event.identificacion;

      final notificacionId =
          await _solicitarRegistro.execute(
        identificacionResidente:
            event.identificacionResidente,
        manzana: event.manzana,
        villa: event.villa,
        identificacion: event.identificacion,
        nombres: event.nombres,
        apellidos: event.apellidos,
        fechaNacimiento:
            event.fechaNacimiento,
        parentesco: event.parentesco,
        parentescoOtroDesc:
            event.parentescoOtroDesc,
        correo: event.correo,
        celular: event.celular,
      );

      emit(EsperandoAutorizacion(
        mensaje:
            'Solicitud enviada. Esperando autorización del titular...',
        notificacionId: notificacionId,
      ));

      _iniciarPolling();
    } catch (e) {
      final errorMsg = e.toString();

      if (errorMsg.contains('409') ||
          errorMsg
              .contains('solicitud pendiente')) {
        _identificacion =
            event.identificacion;
        emit(EsperandoAutorizacion(
          mensaje:
              'Ya tienes una solicitud pendiente. Esperando autorización...',
          notificacionId: 0,
        ));
        _iniciarPolling();
      } else {
        emit(AutorizacionMiembroError(
            'Error al enviar solicitud: $errorMsg'));
      }
    }
  }

  Future<void> _onConsultarEstado(
    EstadoSolicitudConsultada event,
    Emitter<AutorizacionMiembroState> emit,
  ) async {
    if (_identificacion == null) return;

    try {
      final estado = await _consultarEstado
          .execute(_identificacion!);

      switch (estado.estado) {
        case EstadoSolicitud.aprobado:
          _pollingTimer?.cancel();
          emit(AutorizacionAprobada(
            personaId: estado.personaId!,
            miembroId: estado.miembroId,
          ));
          break;
        case EstadoSolicitud.rechazado:
          _pollingTimer?.cancel();
          emit(AutorizacionRechazada(
              motivo: estado.motivo));
          break;
        case EstadoSolicitud.pendiente:
        case EstadoSolicitud.noEncontrado:
          break;
      }
    } catch (e) {
      // Error de red - reintentará en 5s
    }
  }

  void _onCancelar(
    SolicitudCancelada event,
    Emitter<AutorizacionMiembroState> emit,
  ) {
    _pollingTimer?.cancel();
    emit(AutorizacionMiembroInicial());
  }

  void _iniciarPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => add(EstadoSolicitudConsultada()),
    );
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
