part of 'vivienda_bloc.dart';

sealed class ViviendaEvent
    extends Equatable {
  const ViviendaEvent();
  @override
  List<Object?> get props => [];
}

class LoadViviendas
    extends ViviendaEvent {
  final String? manzana;
  final String? estado;
  const LoadViviendas(
      {this.manzana, this.estado});
  @override
  List<Object?> get props =>
      [manzana, estado];
}

class LoadMoreViviendas
    extends ViviendaEvent {
  const LoadMoreViviendas();
}

class CreateVivienda
    extends ViviendaEvent {
  final String manzana;
  final String villa;
  const CreateVivienda(
      {required this.manzana,
      required this.villa});
  @override
  List<Object?> get props =>
      [manzana, villa];
}

class UpdateVivienda
    extends ViviendaEvent {
  final int viviendaId;
  final String? manzana;
  final String? villa;
  const UpdateVivienda(
      {required this.viviendaId,
      this.manzana,
      this.villa});
  @override
  List<Object?> get props =>
      [viviendaId, manzana, villa];
}

class ToggleViviendaEstado
    extends ViviendaEvent {
  final int viviendaId;
  final String estado;
  final String? motivo;
  const ToggleViviendaEstado({
    required this.viviendaId,
    required this.estado,
    this.motivo,
  });
  @override
  List<Object?> get props =>
      [viviendaId, estado, motivo];
}
