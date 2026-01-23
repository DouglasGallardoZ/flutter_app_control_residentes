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
