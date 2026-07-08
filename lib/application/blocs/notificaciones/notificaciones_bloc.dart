import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/notificacion_item.dart';
import '../../../domain/usecases/obtener_notificaciones_usecase.dart';
import '../../../domain/usecases/obtener_no_leidas_usecase.dart';
import '../../../domain/usecases/marcar_notificacion_leida_usecase.dart';
import '../../../domain/usecases/marcar_todas_leidas_usecase.dart';
import '../../../domain/usecases/eliminar_notificacion_usecase.dart';

part 'notificaciones_event.dart';
part 'notificaciones_state.dart';

class NotificacionesBloc
    extends Bloc<NotificacionesEvent, NotificacionesState> {
  final ObtenerNotificacionesUseCase _obtenerNotificaciones;
  final ObtenerNoLeidasUseCase _obtenerNoLeidas;
  final MarcarNotificacionLeidaUseCase _marcarComoLeida;
  final MarcarTodasLeidasUseCase _marcarTodasComoLeidas;
  final EliminarNotificacionUseCase _eliminarNotificacion;

  String? _usuarioId;

  NotificacionesBloc({
    required ObtenerNotificacionesUseCase
        obtenerNotificaciones,
    required ObtenerNoLeidasUseCase obtenerNoLeidas,
    required MarcarNotificacionLeidaUseCase
        marcarComoLeida,
    required MarcarTodasLeidasUseCase
        marcarTodasComoLeidas,
    required EliminarNotificacionUseCase
        eliminarNotificacion,
  })  : _obtenerNotificaciones = obtenerNotificaciones,
        _obtenerNoLeidas = obtenerNoLeidas,
        _marcarComoLeida = marcarComoLeida,
        _marcarTodasComoLeidas = marcarTodasComoLeidas,
        _eliminarNotificacion = eliminarNotificacion,
        super(NotificacionesCargando()) {
    on<NotificacionesIniciadas>(_onIniciadas);
    on<NotificacionesRefrescadas>(_onRefrescadas);
    on<NotificacionMarcadaLeida>(_onMarcarLeida);
    on<TodasNotificacionesMarcadasLeidas>(
        _onMarcarTodasLeidas);
    on<NotificacionEliminada>(_onEliminar);
  }

  Future<void> _onIniciadas(
    NotificacionesIniciadas event,
    Emitter<NotificacionesState> emit,
  ) async {
    _usuarioId = event.usuarioId;
    await _cargarNotificaciones(emit);
  }

  Future<void> _onRefrescadas(
    NotificacionesRefrescadas event,
    Emitter<NotificacionesState> emit,
  ) async {
    await _cargarNotificaciones(emit);
  }

  Future<void> _cargarNotificaciones(
      Emitter<NotificacionesState> emit) async {
    if (_usuarioId == null) return;

    emit(NotificacionesCargando());

    try {
      final notificaciones = await _obtenerNotificaciones
          .execute(_usuarioId!);
      final noLeidas =
          await _obtenerNoLeidas.execute(_usuarioId!);

      if (notificaciones.isEmpty) {
        emit(NotificacionesVacias());
      } else {
        emit(NotificacionesCargadas(
          notificaciones: notificaciones,
          noLeidas: noLeidas,
        ));
      }
    } catch (e) {
      emit(NotificacionesError(e.toString()));
    }
  }

  Future<void> _onMarcarLeida(
    NotificacionMarcadaLeida event,
    Emitter<NotificacionesState> emit,
  ) async {
    if (_usuarioId == null) return;

    try {
      await _marcarComoLeida.execute(
          _usuarioId!, event.notificacionId);

      if (state is NotificacionesCargadas) {
        final currentState =
            state as NotificacionesCargadas;
        final nuevasNotificaciones = currentState
            .notificaciones
            .map((n) {
          if (n.id == event.notificacionId) {
            return NotificacionItem(
              id: n.id,
              titulo: n.titulo,
              cuerpo: n.cuerpo,
              tipo: n.tipo,
              prioridad: n.prioridad,
              categoria: n.categoria,
              leido: true,
              fechaCreacion: n.fechaCreacion,
              rutaAccion: n.rutaAccion,
              datosAccion: n.datosAccion,
            );
          }
          return n;
        }).toList();

        emit(NotificacionesCargadas(
          notificaciones: nuevasNotificaciones,
          noLeidas: currentState.noLeidas - 1,
        ));
      }
    } catch (e) {
      emit(NotificacionesError(e.toString()));
    }
  }

  Future<void> _onMarcarTodasLeidas(
    TodasNotificacionesMarcadasLeidas event,
    Emitter<NotificacionesState> emit,
  ) async {
    if (_usuarioId == null) return;

    try {
      await _marcarTodasComoLeidas
          .execute(_usuarioId!);
      await _cargarNotificaciones(emit);
      emit(NotificacionesOperacionExitosa(
          'Todas las notificaciones marcadas como leídas'));
    } catch (e) {
      emit(NotificacionesError(e.toString()));
    }
  }

  Future<void> _onEliminar(
    NotificacionEliminada event,
    Emitter<NotificacionesState> emit,
  ) async {
    if (_usuarioId == null) return;

    try {
      await _eliminarNotificacion.execute(
          _usuarioId!, event.notificacionId);
      await _cargarNotificaciones(emit);
      emit(NotificacionesOperacionExitosa(
          'Notificación eliminada'));
    } catch (e) {
      emit(NotificacionesError(e.toString()));
    }
  }
}
