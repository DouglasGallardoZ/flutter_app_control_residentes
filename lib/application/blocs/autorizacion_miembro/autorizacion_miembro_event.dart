part of 'autorizacion_miembro_bloc.dart';

abstract class AutorizacionMiembroEvent {}

class SolicitudEnviada
    extends AutorizacionMiembroEvent {
  final String identificacionResidente;
  final String manzana;
  final String villa;
  final String identificacion;
  final String nombres;
  final String apellidos;
  final String fechaNacimiento;
  final String parentesco;
  final String? parentescoOtroDesc;
  final String? correo;
  final String? celular;

  SolicitudEnviada({
    required this.identificacionResidente,
    required this.manzana,
    required this.villa,
    required this.identificacion,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.parentesco,
    this.parentescoOtroDesc,
    this.correo,
    this.celular,
  });
}

class EstadoSolicitudConsultada
    extends AutorizacionMiembroEvent {}

class SolicitudCancelada
    extends AutorizacionMiembroEvent {}
