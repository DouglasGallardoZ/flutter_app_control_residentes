import 'package:equatable/equatable.dart';

abstract class AdminAccountState extends Equatable {
  const AdminAccountState();

  @override
  List<Object?> get props => [];
}

class AdminAccountInitial extends AdminAccountState {
  const AdminAccountInitial();
}

class AdminAccountLoading extends AdminAccountState {
  const AdminAccountLoading();
}

class AccountsSearched extends AdminAccountState {
  final List<Map<String, dynamic>> accounts;

  const AccountsSearched({required this.accounts});

  @override
  List<Object?> get props => [accounts];
}

class AccountBlocked extends AdminAccountState {
  final String message;

  const AccountBlocked({required this.message});

  @override
  List<Object?> get props => [message];
}

class AccountUnblocked extends AdminAccountState {
  final String message;

  const AccountUnblocked({required this.message});

  @override
  List<Object?> get props => [message];
}

class AccountDeleted extends AdminAccountState {
  final String message;

  const AccountDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

class PasswordReset extends AdminAccountState {
  final String message;

  const PasswordReset({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminAccountError extends AdminAccountState {
  final String message;

  const AdminAccountError({required this.message});

  @override
  List<Object?> get props => [message];
}
