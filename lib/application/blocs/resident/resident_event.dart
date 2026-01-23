import 'package:equatable/equatable.dart';

abstract class ResidentEvent extends Equatable {
  const ResidentEvent();

  @override
  List<Object?> get props => [];
}

/// Crear un nuevo residente
class CreateResidentEvent extends ResidentEvent {
  final String identificacion;
  final String tipoIdentificacion;
  final String nombres;
  final String apellidos;
  final String fechaNacimiento;
  final String correo;
  final String celular;
  final String manzana;
  final String villa;
  final String? nacionalidad;
  final String? direccionAlternativa;
  final String? docAutorizacionPdf;
  final String usuarioCreado;

  const CreateResidentEvent({
    required this.identificacion,
    required this.tipoIdentificacion,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.correo,
    required this.celular,
    required this.manzana,
    required this.villa,
    this.nacionalidad,
    this.direccionAlternativa,
    this.docAutorizacionPdf,
    required this.usuarioCreado,
  });

  @override
  List<Object?> get props => [
    identificacion,
    tipoIdentificacion,
    nombres,
    apellidos,
    fechaNacimiento,
    correo,
    celular,
    manzana,
    villa,
    nacionalidad,
    direccionAlternativa,
    docAutorizacionPdf,
    usuarioCreado,
  ];
}

/// Cargar lista de residentes
class LoadResidentsEvent extends ResidentEvent {
  const LoadResidentsEvent();
}

/// Cargar residentes por ubicación
class LoadResidentsByLocationEvent extends ResidentEvent {
  final String manzana;
  final String villa;

  const LoadResidentsByLocationEvent({
    required this.manzana,
    required this.villa,
  });

  @override
  List<Object?> get props => [manzana, villa];
}

/// Obtener residente específico
class GetResidentEvent extends ResidentEvent {
  final String personaId;

  const GetResidentEvent(this.personaId);

  @override
  List<Object?> get props => [personaId];
}

/// Desactivar residente
class DeactivateResidentEvent extends ResidentEvent {
  final int personaId;
  final String reason;

  const DeactivateResidentEvent({
    required this.personaId,
    required this.reason,
  });

  @override
  List<Object?> get props => [personaId, reason];
}

/// Reactivar residente
class ReactivateResidentEvent extends ResidentEvent {
  final int personaId;
  final String reason;

  const ReactivateResidentEvent({
    required this.personaId,
    required this.reason,
  });

  @override
  List<Object?> get props => [personaId, reason];
}

/// Eliminar residente
class DeleteResidentEvent extends ResidentEvent {
  final int personaId;

  const DeleteResidentEvent(this.personaId);

  @override
  List<Object?> get props => [personaId];
}
