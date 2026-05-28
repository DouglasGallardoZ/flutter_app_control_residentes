abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class CreateFirebaseAccountSubmitted extends AuthEvent {
  final String email;
  final String password;

  CreateFirebaseAccountSubmitted({
    required this.email,
    required this.password,
  });
}
