import 'package:equatable/equatable.dart';
import '../../../domain/entities/owner_entity.dart';

abstract class OwnerEvent extends Equatable {
  const OwnerEvent();

  @override
  List<Object?> get props => [];
}

class LoadOwnersByLocationEvent extends OwnerEvent {
  final String manzana;
  final String villa;
  final int page;
  final int pageSize;

  const LoadOwnersByLocationEvent({
    required this.manzana,
    required this.villa,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [manzana, villa, page, pageSize];
}

class BlockOwnerEvent extends OwnerEvent {
  final int ownerId;
  final String reason;

  const BlockOwnerEvent(this.ownerId, this.reason);

  @override
  List<Object?> get props => [ownerId, reason];
}

class UnblockOwnerEvent extends OwnerEvent {
  final int ownerId;
  final String reason;

  const UnblockOwnerEvent(this.ownerId, this.reason);

  @override
  List<Object?> get props => [ownerId, reason];
}

class DeleteOwnerEvent extends OwnerEvent {
  final int ownerId;

  const DeleteOwnerEvent(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class GetOwnerPropertiesEvent extends OwnerEvent {
  final int ownerId;

  const GetOwnerPropertiesEvent(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class CreateOwnerEvent extends OwnerEvent {
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
  final String usuarioCreado;
  final bool fromChangeOwner;

  const CreateOwnerEvent({
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
    required this.usuarioCreado,
    this.fromChangeOwner = false,
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
    usuarioCreado,
    fromChangeOwner,
  ];
}
// ===== EVENTOS PARA CÓNYUGES =====

class LoadOwnerWithSpousesEvent extends OwnerEvent {
  final int ownerId;

  const LoadOwnerWithSpousesEvent(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class CreateSpouseEvent extends OwnerEvent {
  final int ownerId;
  final String tipoIdentificacion;
  final String identificacion;
  final String nombre;
  final String apellido;
  final String fechaNacimiento;
  final String nacionalidad;
  final String correo;
  final String celular;
  final String? direccionAlternativa;
  final String usuarioCreado;

  const CreateSpouseEvent({
    required this.ownerId,
    required this.tipoIdentificacion,
    required this.identificacion,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.nacionalidad,
    required this.correo,
    required this.celular,
    this.direccionAlternativa,
    required this.usuarioCreado,
  });

  @override
  List<Object?> get props => [
    ownerId,
    tipoIdentificacion,
    identificacion,
    nombre,
    apellido,
    fechaNacimiento,
    nacionalidad,
    correo,
    celular,
    direccionAlternativa,
    usuarioCreado,
  ];
}

class DeleteSpouseEvent extends OwnerEvent {
  final int spouseId;

  const DeleteSpouseEvent(this.spouseId);

  @override
  List<Object?> get props => [spouseId];
}

class BlockSpouseEvent extends OwnerEvent {
  final int spouseId;
  final bool block;

  const BlockSpouseEvent(this.spouseId, this.block);

  @override
  List<Object?> get props => [spouseId, block];
}

class LoadActiveOwners extends OwnerEvent {
  const LoadActiveOwners();
}

class UpdateOwnerEvent extends OwnerEvent {
  final int ownerId;
  final String? correo;
  final String? celular;

  const UpdateOwnerEvent({
    required this.ownerId,
    this.correo,
    this.celular,
  });

  @override
  List<Object?> get props => [ownerId, correo, celular];
}