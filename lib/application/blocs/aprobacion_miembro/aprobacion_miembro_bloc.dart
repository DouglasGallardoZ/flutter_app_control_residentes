import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/solicitud_miembro.dart';
import '../../../domain/usecases/listar_solicitudes_pendientes_usecase.dart';
import '../../../domain/usecases/aprobar_solicitud_miembro_usecase.dart';
import '../../../domain/usecases/rechazar_solicitud_miembro_usecase.dart';

part 'aprobacion_miembro_event.dart';
part 'aprobacion_miembro_state.dart';

class AprobacionMiembroBloc extends Bloc<
    AprobacionMiembroEvent,
    AprobacionMiembroState> {
  final ListarSolicitudesPendientesUseCase
      _listarPendientes;
  final AprobarSolicitudMiembroUseCase _aprobar;
  final RechazarSolicitudMiembroUseCase _rechazar;

  AprobacionMiembroBloc({
    required ListarSolicitudesPendientesUseCase
        listarPendientes,
    required AprobarSolicitudMiembroUseCase
        aprobar,
    required RechazarSolicitudMiembroUseCase
        rechazar,
  })  : _listarPendientes = listarPendientes,
        _aprobar = aprobar,
        _rechazar = rechazar,
        super(AprobacionMiembroInicial()) {
    on<CargarSolicitudesPendientes>(
        _onCargarSolicitudes);
    on<AprobarSolicitud>(_onAprobar);
    on<RechazarSolicitud>(_onRechazar);
    on<RecargarSolicitudes>(_onRecargar);
  }

  Future<void> _onCargarSolicitudes(
    CargarSolicitudesPendientes event,
    Emitter<AprobacionMiembroState> emit,
  ) async {
    emit(AprobacionMiembroCargando());
    try {
      final solicitudes =
          await _listarPendientes.execute();
      if (solicitudes.isEmpty) {
        emit(AprobacionMiembroVacio());
      } else {
        emit(SolicitudesPendientesCargadas(
            solicitudes: solicitudes));
      }
    } catch (e) {
      emit(AprobacionMiembroError(
          mensaje: e.toString()));
    }
  }

  Future<void> _onAprobar(
    AprobarSolicitud event,
    Emitter<AprobacionMiembroState> emit,
  ) async {
    emit(AprobacionMiembroProcesando(
        mensaje: 'Aprobando solicitud...'));
    try {
      final resultado =
          await _aprobar.execute(event.solicitudId);
      emit(SolicitudAprobadaExitosa(
        personaId: resultado['persona_id'],
        miembroId: resultado['miembro_id'],
        mensaje: resultado['mensaje'] ??
            'Miembro aprobado exitosamente',
      ));
      add(RecargarSolicitudes());
    } catch (e) {
      emit(AprobacionMiembroError(
          mensaje:
              'Error al aprobar: ${e.toString()}'));
      add(RecargarSolicitudes());
    }
  }

  Future<void> _onRechazar(
    RechazarSolicitud event,
    Emitter<AprobacionMiembroState> emit,
  ) async {
    emit(AprobacionMiembroProcesando(
        mensaje: 'Rechazando solicitud...'));
    try {
      await _rechazar.execute(
          event.solicitudId,
          motivo: event.motivo);
      emit(SolicitudRechazadaExitosa(
          mensaje: 'Solicitud rechazada'));
      add(RecargarSolicitudes());
    } catch (e) {
      emit(AprobacionMiembroError(
          mensaje:
              'Error al rechazar: ${e.toString()}'));
      add(RecargarSolicitudes());
    }
  }

  Future<void> _onRecargar(
    RecargarSolicitudes event,
    Emitter<AprobacionMiembroState> emit,
  ) async {
    await Future.delayed(
        const Duration(milliseconds: 500));
    add(CargarSolicitudesPendientes());
  }
}
