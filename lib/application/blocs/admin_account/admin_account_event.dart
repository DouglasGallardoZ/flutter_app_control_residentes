import 'package:equatable/equatable.dart';

abstract class AdminAccountEvent extends Equatable {
  const AdminAccountEvent();

  @override
  List<Object?> get props => [];
}

class SearchAccountByEmailEvent extends AdminAccountEvent {
  final String email;

  const SearchAccountByEmailEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class SearchAccountByLocationEvent extends AdminAccountEvent {
  final String manzana;
  final String villa;

  const SearchAccountByLocationEvent({
    required this.manzana,
    required this.villa,
  });

  @override
  List<Object?> get props => [manzana, villa];
}

class BlockAccountEvent extends AdminAccountEvent {
  final int accountId;
  final String reason;
  final bool cascada;

  const BlockAccountEvent({
    required this.accountId,
    required this.reason,
    this.cascada = false,
  });

  @override
  List<Object?> get props => [accountId, reason, cascada];
}

class UnblockAccountEvent extends AdminAccountEvent {
  final int accountId;
  final String reason;
  final bool cascada;

  const UnblockAccountEvent({
    required this.accountId,
    required this.reason,
    this.cascada = false,
  });

  @override
  List<Object?> get props => [accountId, reason, cascada];
}

class DeleteAccountEvent extends AdminAccountEvent {
  final int accountId;

  const DeleteAccountEvent({required this.accountId});

  @override
  List<Object?> get props => [accountId];
}

class ResetPasswordEvent extends AdminAccountEvent {
  final int accountId;
  final String newPassword;

  const ResetPasswordEvent({
    required this.accountId,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [accountId, newPassword];
}
