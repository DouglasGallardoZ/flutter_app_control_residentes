part of 'vivienda_bloc.dart';

sealed class ViviendaState
    extends Equatable {
  const ViviendaState();
  @override
  List<Object?> get props => [];
}

class ViviendaInitial
    extends ViviendaState {
  const ViviendaInitial();
}

class ViviendaLoading
    extends ViviendaState {
  const ViviendaLoading();
}

class ViviendaLoaded
    extends ViviendaState {
  final List<ViviendaEntity> viviendas;
  final bool hasNext;
  const ViviendaLoaded(
      {required this.viviendas,
      required this.hasNext});
  @override
  List<Object?> get props =>
      [viviendas, hasNext];
}

class ViviendaCreated
    extends ViviendaState {
  const ViviendaCreated();
}

class ViviendaUpdated
    extends ViviendaState {
  const ViviendaUpdated();
}

class ViviendaEstadoChanged
    extends ViviendaState {
  final int viviendaId;
  final String nuevoEstado;
  final String mensaje;
  const ViviendaEstadoChanged({
    required this.viviendaId,
    required this.nuevoEstado,
    required this.mensaje,
  });
  @override
  List<Object?> get props =>
      [viviendaId, nuevoEstado, mensaje];
}

class ViviendaError
    extends ViviendaState {
  final String mensaje;
  const ViviendaError(
      {required this.mensaje});
  @override
  List<Object?> get props =>
      [mensaje];
}
