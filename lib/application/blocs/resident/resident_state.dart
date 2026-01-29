import 'package:equatable/equatable.dart';

abstract class ResidentState extends Equatable {
  const ResidentState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ResidentInitial extends ResidentState {
  const ResidentInitial();
}

/// Cargando
class ResidentLoading extends ResidentState {
  const ResidentLoading();
}

/// Residente creado exitosamente
class ResidentCreated extends ResidentState {
  final Map<String, dynamic> resident;
  final String message;

  const ResidentCreated({
    required this.resident,
    required this.message,
  });

  @override
  List<Object?> get props => [resident, message];
}

/// Residentes cargados
class ResidentsLoaded extends ResidentState {
  final List<Map<String, dynamic>> residents;

  const ResidentsLoaded(this.residents);

  @override
  List<Object?> get props => [residents];
}

/// Residentes cargados por ubicación
class ResidentsByLocationLoaded extends ResidentState {
  final List<Map<String, dynamic>> residents;
  final String manzana;
  final String villa;

  const ResidentsByLocationLoaded({
    required this.residents,
    required this.manzana,
    required this.villa,
  });

  @override
  List<Object?> get props => [residents, manzana, villa];
}

/// Residente obtenido
class ResidentLoaded extends ResidentState {
  final Map<String, dynamic> resident;

  const ResidentLoaded(this.resident);

  @override
  List<Object?> get props => [resident];
}

/// Residente desactivado
class ResidentDeactivated extends ResidentState {
  final String message;
  final String reason;

  const ResidentDeactivated(this.message, [this.reason = '']);

  @override
  List<Object?> get props => [message, reason];
}

/// Residente reactivado
class ResidentReactivated extends ResidentState {
  final String message;
  final String reason;

  const ResidentReactivated(this.message, [this.reason = '']);

  @override
  List<Object?> get props => [message, reason];
}

/// Residente eliminado
class ResidentDeleted extends ResidentState {
  final String message;

  const ResidentDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error
class ResidentError extends ResidentState {
  final String message;

  const ResidentError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Accesos de vivienda cargados
class ResidenceAccessesLoaded extends ResidentState {
  final Map<String, dynamic> accessesData;
  final int viviendaId;

  const ResidenceAccessesLoaded({
    required this.accessesData,
    required this.viviendaId,
  });

  @override
  List<Object?> get props => [accessesData, viviendaId];
}
