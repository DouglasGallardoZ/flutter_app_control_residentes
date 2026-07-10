import 'package:equatable/equatable.dart';
import '../../../domain/entities/qr_generado.dart';

abstract class QrListState extends Equatable {
  const QrListState();

  @override
  List<Object?> get props => [];
}

class QrListInitial extends QrListState {
  const QrListInitial();
}

class QrListLoading extends QrListState {
  const QrListLoading();
}

class QrListLoaded extends QrListState {
  final List<QrGenerado> qrs;
  final int total;
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final String tipoIngreso;

  const QrListLoaded({
    required this.qrs,
    required this.total,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.tipoIngreso,
  });

  @override
  List<Object?> get props => [qrs, total, currentPage, pageSize, totalPages, hasNext, tipoIngreso];

  QrListLoaded copyWith({
    List<QrGenerado>? qrs,
    int? total,
    int? currentPage,
    int? pageSize,
    int? totalPages,
    bool? hasNext,
    String? tipoIngreso,
  }) {
    return QrListLoaded(
      qrs: qrs ?? this.qrs,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      tipoIngreso: tipoIngreso ?? this.tipoIngreso,
    );
  }
}

class QrListError extends QrListState {
  final String message;

  const QrListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class QrAnuladoExito extends QrListState {
  final String mensaje;

  const QrAnuladoExito({this.mensaje = 'QR anulado exitosamente'});

  @override
  List<Object?> get props => [mensaje];
}
