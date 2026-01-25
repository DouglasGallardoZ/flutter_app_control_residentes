import 'package:equatable/equatable.dart';

abstract class QrListEvent extends Equatable {
  const QrListEvent();

  @override
  List<Object?> get props => [];
}

class LoadQrList extends QrListEvent {
  final String tipoIngreso; // all, propio, visita
  final int page;
  final int pageSize;
  final String usuarioId;

  const LoadQrList({
    this.tipoIngreso = 'all',
    this.page = 1,
    this.pageSize = 10,
    required this.usuarioId,
  });

  @override
  List<Object?> get props => [tipoIngreso, page, pageSize, usuarioId];
}

class FilterQrList extends QrListEvent {
  final String tipoIngreso; // Cambiar filtro y resetear a página 1
  final String usuarioId;

  const FilterQrList({
    required this.tipoIngreso,
    required this.usuarioId,
  });

  @override
  List<Object?> get props => [tipoIngreso, usuarioId];
}

class LoadMoreQrList extends QrListEvent {
  final String usuarioId;

  const LoadMoreQrList({required this.usuarioId});

  @override
  List<Object?> get props => [usuarioId];
}
