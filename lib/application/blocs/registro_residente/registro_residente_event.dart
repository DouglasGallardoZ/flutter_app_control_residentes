import '../../../domain/entities/prospecto_residente.dart';

abstract class RegistroResidenteEvent {}

class RegistroResidenteIniciado extends RegistroResidenteEvent {
  final ProspectoResidente prospecto;
  RegistroResidenteIniciado(this.prospecto);
}

class VerificacionFacialCapturada extends RegistroResidenteEvent {
  final String fotoBiometricaPath;
  VerificacionFacialCapturada(this.fotoBiometricaPath);
}

class VerificacionFacialCompleta extends RegistroResidenteEvent {
  final bool esValida;
  final double distancia;
  VerificacionFacialCompleta({required this.esValida, required this.distancia});
}

class CredencialesIngresadas extends RegistroResidenteEvent {
  final String correo;
  final String contrasena;
  CredencialesIngresadas({required this.correo, required this.contrasena});
}

class CrearCuentaResidente extends RegistroResidenteEvent {
  final int personaId;
  final String firebaseUid;
  final String email;
  CrearCuentaResidente({
    required this.personaId,
    required this.firebaseUid,
    required this.email,
  });
}

class CrearCuentaMiembro extends RegistroResidenteEvent {
  final int personaId;
  final String firebaseUid;
  final String email;
  CrearCuentaMiembro({
    required this.personaId,
    required this.firebaseUid,
    required this.email,
  });
}

class ResetRegistro extends RegistroResidenteEvent {}
