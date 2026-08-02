import 'package:equatable/equatable.dart';

abstract class MemberEvent extends Equatable {
  const MemberEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar miembros por ubicación (manzana y villa)
class LoadMembersByLocationEvent extends MemberEvent {
  final String manzana;
  final String villa;

  const LoadMembersByLocationEvent({
    required this.manzana,
    required this.villa,
  });

  @override
  List<Object?> get props => [manzana, villa];
}

/// Desactivar un miembro
class DeactivateMemberEvent extends MemberEvent {
  final int memberId;
  final String reason;

  const DeactivateMemberEvent({
    required this.memberId,
    required this.reason,
  });

  @override
  List<Object?> get props => [memberId, reason];
}

/// Reactivar un miembro
class ReactivateMemberEvent extends MemberEvent {
  final int memberId;
  final String reason;

  const ReactivateMemberEvent({
    required this.memberId,
    required this.reason,
  });

  @override
  List<Object?> get props => [memberId, reason];
}

/// Bloquear un miembro (desde rol residente)
class BloquearMiembroEvent extends MemberEvent {
  final int memberId;
  final String reason;

  const BloquearMiembroEvent({
    required this.memberId,
    required this.reason,
  });

  @override
  List<Object?> get props => [memberId, reason];
}

/// Desbloquear un miembro (desde rol residente)
class DesbloquearMiembroEvent extends MemberEvent {
  final int memberId;
  final String reason;

  const DesbloquearMiembroEvent({
    required this.memberId,
    required this.reason,
  });

  @override
  List<Object?> get props => [memberId, reason];
}

/// Eliminar un miembro
class DeleteMemberEvent extends MemberEvent {
  final int memberId;
  final String motivo;

  const DeleteMemberEvent(this.memberId, [this.motivo = '']);

  @override
  List<Object?> get props => [memberId, motivo];
}

/// Crear/agregar un nuevo miembro de familia
class CreateMemberEvent extends MemberEvent {
  final String residenteId;
  final String identificacion;
  final String tipoIdentificacion;
  final String nombres;
  final String apellidos;
  final String fechaNacimiento;
  final String manzana;
  final String villa;
  final String parentesco;
  final String? nacionalidad;
  final String? correo;
  final String? celular;
  final String? direccionAlternativa;
  final String? parentescoOtroDesc;
  final String usuarioCreado;

  const CreateMemberEvent({
    required this.residenteId,
    required this.identificacion,
    required this.tipoIdentificacion,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.manzana,
    required this.villa,
    required this.parentesco,
    this.nacionalidad,
    this.correo,
    this.celular,
    this.direccionAlternativa,
    this.parentescoOtroDesc,
    required this.usuarioCreado,
  });

  @override
  List<Object?> get props => [
    residenteId,
    identificacion,
    tipoIdentificacion,
    nombres,
    apellidos,
    fechaNacimiento,
    manzana,
    villa,
    parentesco,
    nacionalidad,
    correo,
    celular,
    direccionAlternativa,
    parentescoOtroDesc,
    usuarioCreado,
  ];
}
