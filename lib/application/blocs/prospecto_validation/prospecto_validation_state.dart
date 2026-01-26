import '../../../domain/entities/prospecto_residente.dart';

abstract class ProspectoValidationState {}

class ProspectoValidationInitial extends ProspectoValidationState {}

class ProspectoValidationLoading extends ProspectoValidationState {}

class ProspectoResidenteValidado extends ProspectoValidationState {
  final ProspectoResidente prospecto;
  ProspectoResidenteValidado(this.prospecto);
}

class ProspectoMiembroValidado extends ProspectoValidationState {
  final ProspectoMiembro prospecto;
  ProspectoMiembroValidado(this.prospecto);
}

class ProspectoValidationError extends ProspectoValidationState {
  final String message;
  ProspectoValidationError(this.message);
}
