import 'package:equatable/equatable.dart';

abstract class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MemberInitial extends MemberState {
  const MemberInitial();
}

/// Cargando miembros
class MemberLoading extends MemberState {
  const MemberLoading();
}

/// Miembros cargados por ubicación
class MembersByLocationLoaded extends MemberState {
  final List<Map<String, dynamic>> members;
  final String manzana;
  final String villa;

  const MembersByLocationLoaded({
    required this.members,
    required this.manzana,
    required this.villa,
  });

  @override
  List<Object?> get props => [members, manzana, villa];
}

/// Miembro desactivado
class MemberDeactivated extends MemberState {
  final String message;
  final String reason;

  const MemberDeactivated({
    required this.message,
    required this.reason,
  });

  @override
  List<Object?> get props => [message, reason];
}

/// Miembro reactivado
class MemberReactivated extends MemberState {
  final String message;
  final String reason;

  const MemberReactivated({
    required this.message,
    required this.reason,
  });

  @override
  List<Object?> get props => [message, reason];
}

/// Miembro eliminado
class MemberDeleted extends MemberState {
  final String message;

  const MemberDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Miembro creado/agregado
class MemberCreated extends MemberState {
  final String message;
  final Map<String, dynamic> member;

  const MemberCreated({
    required this.message,
    required this.member,
  });

  @override
  List<Object?> get props => [message, member];
}

/// Error al procesar operación
class MemberError extends MemberState {
  final String message;

  const MemberError({required this.message});

  @override
  List<Object?> get props => [message];
}
