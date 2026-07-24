import 'package:equatable/equatable.dart';
import '../../../domain/entities/owner_entity.dart';
import '../../../domain/entities/conyuge_entity.dart';

abstract class OwnerState extends Equatable {
  const OwnerState();

  @override
  List<Object?> get props => [];
}

class OwnerInitial extends OwnerState {
  const OwnerInitial();
}

class OwnerLoading extends OwnerState {
  const OwnerLoading();
}

class OwnersByLocationLoaded extends OwnerState {
  final List<OwnerEntity> owners;
  final String manzana;
  final String villa;
  final int currentPage;
  final bool hasMore;

  const OwnersByLocationLoaded({
    required this.owners,
    required this.manzana,
    required this.villa,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [owners, manzana, villa, currentPage, hasMore];
}

class OwnerBlocked extends OwnerState {
  final String message;
  final String reason;

  const OwnerBlocked(this.message, [this.reason = '']);

  @override
  List<Object?> get props => [message, reason];
}

class OwnerUnblocked extends OwnerState {
  final String message;
  final String reason;

  const OwnerUnblocked(this.message, [this.reason = '']);

  @override
  List<Object?> get props => [message, reason];
}

class OwnerDeleted extends OwnerState {
  final String message;

  const OwnerDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class OwnerCreated extends OwnerState {
  final String message;
  final Map<String, dynamic> owner;

  const OwnerCreated({required this.message, required this.owner});

  @override
  List<Object?> get props => [message, owner];
}

class OwnerPropertiesLoaded extends OwnerState {
  final List<Map<String, dynamic>> properties;

  const OwnerPropertiesLoaded(this.properties);

  @override
  List<Object?> get props => [properties];
}

class OwnerError extends OwnerState {
  final String message;

  const OwnerError(this.message);

  @override
  List<Object?> get props => [message];
}

// ===== ESTADOS PARA CÓNYUGES =====

class OwnerWithSpousesLoaded extends OwnerState {
  final OwnerWithSpousesEntity owner;

  const OwnerWithSpousesLoaded(this.owner);

  @override
  List<Object?> get props => [owner];
}

class SpouseCreating extends OwnerState {
  const SpouseCreating();
}

class SpouseCreated extends OwnerState {
  final ConyugeEntity spouse;

  const SpouseCreated(this.spouse);

  @override
  List<Object?> get props => [spouse];
}

class SpouseDeleted extends OwnerState {
  final String message;

  const SpouseDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class SpouseBlocked extends OwnerState {
  final String message;
  final bool blocked;

  const SpouseBlocked(this.message, this.blocked);

  @override
  List<Object?> get props => [message, blocked];
}

class SpouseError extends OwnerState {
  final String message;
  const SpouseError(this.message);
  @override
  List<Object?> get props => [message];
}

class OwnersLoading extends OwnerState {
  const OwnersLoading();
}

class OwnersLoaded extends OwnerState {
  final List<Map<String, dynamic>> owners;
  const OwnersLoaded(this.owners);
}

