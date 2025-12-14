import '../../../domain/entities/account.dart';

abstract class AccountEvent {}

class RegisterAccountSubmitted extends AccountEvent {
  final Account account;
  RegisterAccountSubmitted(this.account);
}

class UpdateEmailSubmitted extends AccountEvent {
  final String id;
  final String newEmail;
  UpdateEmailSubmitted(this.id, this.newEmail);
}
