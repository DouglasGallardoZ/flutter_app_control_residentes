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

/// Eliminar un miembro
class DeleteMemberEvent extends MemberEvent {
  final int memberId;

  const DeleteMemberEvent(this.memberId);

  @override
  List<Object?> get props => [memberId];
}
