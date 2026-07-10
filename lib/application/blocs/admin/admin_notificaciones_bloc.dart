import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/destinatario.dart';
import '../../../domain/ports/admin_notificaciones_repository_port.dart';

part 'admin_notificaciones_event.dart';
part 'admin_notificaciones_state.dart';

class AdminNotificacionesBloc extends Bloc<
    AdminNotificacionesEvent, AdminNotificacionesState> {
  final AdminNotificacionesRepositoryPort _repository;

  AdminNotificacionesBloc(this._repository)
      : super(AdminNotificacionesInicial()) {
    on<AdminDestinatariosSolicitados>(
        _onCargarDestinatarios);
    on<AdminDestinatarioSeleccionado>(
        _onSeleccionarDestinatario);
    on<AdminSeleccionarTodos>(_onSeleccionarTodos);
    on<AdminDeseleccionarTodos>(
        _onDeseleccionarTodos);
    on<AdminNotificacionEnviada>(
        _onEnviarNotificacion);
    on<AdminFiltroManzanaCambiado>(
        _onFiltroManzanaCambiado);
    on<AdminFiltroVillaCambiado>(
        _onFiltroVillaCambiado);
  }

  Future<void> _onCargarDestinatarios(
    AdminDestinatariosSolicitados event,
    Emitter<AdminNotificacionesState> emit,
  ) async {
    final manzanaActual = state is AdminDestinatariosCargados
        ? (state as AdminDestinatariosCargados)
            .manzanaSeleccionada
        : null;
    final villaActual = state is AdminDestinatariosCargados
        ? (state as AdminDestinatariosCargados)
            .villaSeleccionada
        : null;

    emit(AdminNotificacionesCargando());
    try {
      final resultados = await Future.wait([
        _repository.obtenerDestinatarios(
          busqueda: event.busqueda,
          manzana: manzanaActual,
          villa: villaActual,
        ),
        _repository.obtenerManzanas(),
      ]).timeout(const Duration(seconds: 15));

      final destinatarios =
          resultados[0] as List<Destinatario>;
      final manzanas = resultados[1] as List<String>;

      print(
          'Cargados: ${destinatarios.length} dest, ${manzanas.length} mz, filtro='
          'mz:$manzanaActual villa:$villaActual');

      emit(AdminDestinatariosCargados(
        destinatarios: destinatarios,
        seleccionados: 0,
        manzanas: manzanas,
        manzanaSeleccionada: manzanaActual,
        villaSeleccionada: villaActual,
      ));
    } on TimeoutException {
      emit(AdminNotificacionesError(
          'Tiempo de espera agotado. Verifica tu conexión.'));
    } catch (e) {
      print('Error cargando destinatarios: $e');
      emit(AdminNotificacionesError(
          'Error al cargar destinatarios: $e'));
    }
  }

  void _onSeleccionarDestinatario(
    AdminDestinatarioSeleccionado event,
    Emitter<AdminNotificacionesState> emit,
  ) {
    if (state is AdminDestinatariosCargados) {
      final currentState =
          state as AdminDestinatariosCargados;
      final nuevos = currentState.destinatarios.map((d) {
        if (d.personaId == event.personaId) {
          d.seleccionado = !d.seleccionado;
        }
        return d;
      }).toList();
      emit(_cargadosCon(currentState, nuevos));
    }
  }

  void _onSeleccionarTodos(
    AdminSeleccionarTodos event,
    Emitter<AdminNotificacionesState> emit,
  ) {
    if (state is AdminDestinatariosCargados) {
      final currentState =
          state as AdminDestinatariosCargados;
      final nuevos = currentState.destinatarios.map((d) {
        d.seleccionado = true;
        return d;
      }).toList();
      emit(_cargadosCon(currentState, nuevos));
    }
  }

  void _onDeseleccionarTodos(
    AdminDeseleccionarTodos event,
    Emitter<AdminNotificacionesState> emit,
  ) {
    if (state is AdminDestinatariosCargados) {
      final currentState =
          state as AdminDestinatariosCargados;
      final nuevos = currentState.destinatarios.map((d) {
        d.seleccionado = false;
        return d;
      }).toList();
      emit(_cargadosCon(currentState, nuevos));
    }
  }

  AdminDestinatariosCargados _cargadosCon(
    AdminDestinatariosCargados prev,
    List<Destinatario> nuevos,
  ) {
    return AdminDestinatariosCargados(
      destinatarios: nuevos,
      seleccionados:
          nuevos.where((d) => d.seleccionado).length,
      manzanas: prev.manzanas,
      manzanaSeleccionada: prev.manzanaSeleccionada,
      villaSeleccionada: prev.villaSeleccionada,
    );
  }

  Future<void> _onFiltroManzanaCambiado(
    AdminFiltroManzanaCambiado event,
    Emitter<AdminNotificacionesState> emit,
  ) async {
    if (state is AdminDestinatariosCargados) {
      final currentState =
          state as AdminDestinatariosCargados;
      final manzanas = currentState.manzanas;
      final villa =
          event.manzana == null ? null : currentState.villaSeleccionada;

      emit(AdminNotificacionesCargando());

      try {
        final destinatarios =
            await _repository.obtenerDestinatarios(
          manzana: event.manzana,
          villa: villa,
        ).timeout(const Duration(seconds: 15));

        print(
            'Filtro manzana: ${destinatarios.length} destinatarios');

        emit(AdminDestinatariosCargados(
          destinatarios: destinatarios,
          seleccionados: 0,
          manzanas: manzanas,
          manzanaSeleccionada: event.manzana,
          villaSeleccionada: event.manzana == null
              ? null
              : currentState.villaSeleccionada,
        ));
      } on TimeoutException {
        emit(AdminNotificacionesError(
            'Tiempo de espera agotado al filtrar. Intenta de nuevo.'));
      } catch (e) {
        emit(AdminNotificacionesError(
            'Error al filtrar: $e'));
      }
    }
  }

  Future<void> _onFiltroVillaCambiado(
    AdminFiltroVillaCambiado event,
    Emitter<AdminNotificacionesState> emit,
  ) async {
    if (state is AdminDestinatariosCargados) {
      final currentState =
          state as AdminDestinatariosCargados;

      emit(AdminNotificacionesCargando());

      try {
        final destinatarios =
            await _repository.obtenerDestinatarios(
          manzana:
              currentState.manzanaSeleccionada,
          villa: event.villa,
        ).timeout(const Duration(seconds: 15));

        print(
            'Filtro villa: ${destinatarios.length} destinatarios');

        emit(AdminDestinatariosCargados(
          destinatarios: destinatarios,
          seleccionados: 0,
          manzanas: currentState.manzanas,
          manzanaSeleccionada:
              currentState.manzanaSeleccionada,
          villaSeleccionada: event.villa,
        ));
      } on TimeoutException {
        emit(AdminNotificacionesError(
            'Tiempo de espera agotado al filtrar. Intenta de nuevo.'));
      } catch (e) {
        emit(AdminNotificacionesError(
            'Error al filtrar: $e'));
      }
    }
  }

  Future<void> _onEnviarNotificacion(
    AdminNotificacionEnviada event,
    Emitter<AdminNotificacionesState> emit,
  ) async {
    final currentState = state;
    List<int> destinatarioIds = [];

    if (currentState is AdminDestinatariosCargados) {
      destinatarioIds = currentState.destinatarios
          .where((d) => d.seleccionado)
          .map((d) => d.personaId)
          .toList();
    }

    if (!event.enviarATodos &&
        destinatarioIds.isEmpty) {
      emit(AdminNotificacionesError(
          'Selecciona al menos un destinatario'));
      return;
    }

    emit(AdminNotificacionEnviando());

    try {
      await _repository.enviarNotificacion(
        titulo: event.titulo,
        mensaje: event.mensaje,
        prioridad: event.prioridad,
        categoria: event.categoria,
        destinatarioIds: event.enviarATodos ? [] : destinatarioIds,
        enviarATodos: event.enviarATodos,
      ).timeout(const Duration(seconds: 30));

      emit(AdminNotificacionEnviadaExito(
        enviados: event.enviarATodos
            ? (currentState is AdminDestinatariosCargados ? currentState.destinatarios.length : 0)
            : destinatarioIds.length,
        mensaje: event.enviarATodos
            ? 'Notificación enviada a todos los residentes'
            : 'Notificación enviada exitosamente',
      ));
    } on TimeoutException {
      emit(AdminNotificacionesError(
          'La notificación está tardando demasiado. Verifica si se envió correctamente.'));
    } catch (e) {
      emit(AdminNotificacionesError(
          'Error al enviar notificación: $e'));
    }
  }
}
