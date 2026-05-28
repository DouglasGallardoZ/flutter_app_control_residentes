import '../ports/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository authRepository;
  LogoutUseCase(this.authRepository);

  Future<void> execute() async {
    await authRepository.logout();
  }
}
