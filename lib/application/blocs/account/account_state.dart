import '../../../domain/entities/account.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountRegistered extends AccountState {
  final Account account;
  AccountRegistered(this.account);
}

class AccountUpdated extends AccountState {}

class AccountError extends AccountState {
  final String message;
  AccountError(this.message);
}
