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

class ViviendasBulkCreated extends ViviendaState {
  final int creadas;
  final List<String> omitidas;
  final String manzana;
  const ViviendasBulkCreated({required this.creadas, this.omitidas = const [], this.manzana = ''});
  @override
  List<Object?> get props => [creadas, omitidas, manzana];
}

class ManzanasLoading extends ViviendaState {
  const ManzanasLoading();
}

class ManzanasLoaded extends ViviendaState {
  final List<ManzanaResumen> manzanas;
  const ManzanasLoaded({required this.manzanas});
  @override
  List<Object?> get props => [manzanas];
}

class ManzanasError extends ViviendaState {
  final String message;
  const ManzanasError({required this.message});
  @override
  List<Object?> get props => [message];
}

class PropietarioCambiado extends ViviendaState {
  final String mensaje;
  const PropietarioCambiado({required this.mensaje});
  @override
  List<Object?> get props => [mensaje];
}

class VillaDetalleLoaded extends ViviendaState {
  final VillaDetalleEntity detalle;
  const VillaDetalleLoaded({required this.detalle});
  @override
  List<Object?> get props => [detalle];
}

class ManzanaResumen {
  final String manzana;
  final int totalVillas;
  final int villasActivas;
  final int villasInactivas;
  final int totalPropietarios;
  final int totalResidentes;
  final int totalMiembros;

  const ManzanaResumen({
    required this.manzana,
    required this.totalVillas,
    required this.villasActivas,
    required this.villasInactivas,
    required this.totalPropietarios,
    required this.totalResidentes,
    required this.totalMiembros,
  });
}
