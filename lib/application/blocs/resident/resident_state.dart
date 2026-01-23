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

  const ResidentDeactivated(this.message);

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
