abstract class AuthEvent {}
class LoginSubmitted extends AuthEvent {
  final String id;
  final String password;
  LoginSubmitted(this.id, this.password);
}
class LogoutRequested extends AuthEvent {}
