abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted(this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class CreateUserSubmitted extends AuthEvent {
  final String email;
  final String password;

  CreateUserSubmitted({
    required this.email,
    required this.password,
  });
}
