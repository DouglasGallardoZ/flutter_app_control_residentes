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
  }

  Future<void> _onCargarDestinatarios(
    AdminDestinatariosSolicitados event,
    Emitter<AdminNotificacionesState> emit,
  ) async {
    emit(AdminNotificacionesCargando());
    try {
      final destinatarios =
          await _repository.obtenerDestinatarios(
              busqueda: event.busqueda);
      emit(AdminDestinatariosCargados(
        destinatarios: destinatarios,
        seleccionados: 0,
      ));
    } catch (e) {
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
      final nuevosDestinatarios = currentState
          .destinatarios
          .map((d) {
        if (d.personaId == event.personaId) {
          d.seleccionado = !d.seleccionado;
        }
        return d;
      }).toList();
      final seleccionados = nuevosDestinatarios
          .where((d) => d.seleccionado)
          .length;
      emit(AdminDestinatariosCargados(
        destinatarios: nuevosDestinatarios,
        seleccionados: seleccionados,
      ));
    }
  }

  void _onSeleccionarTodos(
    AdminSeleccionarTodos event,
    Emitter<AdminNotificacionesState> emit,
  ) {
    if (state is AdminDestinatariosCargados) {
      final currentState =
          state as AdminDestinatariosCargados;
      final nuevosDestinatarios = currentState
          .destinatarios
          .map((d) {
        d.seleccionado = true;
        return d;
      }).toList();
      emit(AdminDestinatariosCargados(
        destinatarios: nuevosDestinatarios,
        seleccionados: nuevosDestinatarios.length,
      ));
    }
  }

  void _onDeseleccionarTodos(
    AdminDeseleccionarTodos event,
    Emitter<AdminNotificacionesState> emit,
  ) {
    if (state is AdminDestinatariosCargados) {
      final currentState =
          state as AdminDestinatariosCargados;
      final nuevosDestinatarios = currentState
          .destinatarios
          .map((d) {
        d.seleccionado = false;
        return d;
      }).toList();
      emit(AdminDestinatariosCargados(
        destinatarios: nuevosDestinatarios,
        seleccionados: 0,
      ));
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

      print('🔍 BLOC DEBUG:');
      print(
          '  - state seleccionados: ${currentState.seleccionados}');
      print(
          '  - destinatarios totales: ${currentState.destinatarios.length}');
      print('  - IDs recolectados: $destinatarioIds');
    }

    if (!event.enviarATodos &&
        destinatarioIds.isEmpty) {
      print(
          '❌ No hay destinatarios seleccionados y enviarATodos=false');
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
        destinatarioIds: destinatarioIds,
        enviarATodos: event.enviarATodos,
      );

      emit(AdminNotificacionEnviadaExito(
        enviados: event.enviarATodos
            ? 0
            : destinatarioIds.length,
        mensaje:
            'Notificación enviada exitosamente',
      ));
    } catch (e) {
      print('❌ Error enviando: $e');
      emit(AdminNotificacionesError(
          'Error al enviar notificación: $e'));
    }
  }
}
