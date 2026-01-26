import '../../../domain/entities/prospecto_residente.dart';

abstract class RegistroResidenteState {}

class RegistroResidenteInitial extends RegistroResidenteState {}

class RegistroResidenteEnProceso extends RegistroResidenteState {
  final ProspectoResidente prospecto;
  RegistroResidenteEnProceso(this.prospecto);
}

class VerificacionFacialEnProceso extends RegistroResidenteState {
  final ProspectoResidente prospecto;
  VerificacionFacialEnProceso(this.prospecto);
}

class VerificacionFacialExitosa extends RegistroResidenteState {
  final ProspectoResidente prospecto;
  final double distancia;
  VerificacionFacialExitosa(this.prospecto, this.distancia);
}

class VerificacionFacialFallida extends RegistroResidenteState {
  final ProspectoResidente prospecto;
  final String message;
  final double distancia;
  VerificacionFacialFallida(this.prospecto, this.message, this.distancia);
}

class CredencialesEnProceso extends RegistroResidenteState {
  final ProspectoResidente prospecto;
  CredencialesEnProceso(this.prospecto);
}

class CuentaCreada extends RegistroResidenteState {
  final CuentaResponse response;
  CuentaCreada(this.response);
}

class RegistroResidenteError extends RegistroResidenteState {
  final String message;
  RegistroResidenteError(this.message);
}
