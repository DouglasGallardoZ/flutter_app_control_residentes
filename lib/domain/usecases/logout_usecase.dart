import '../ports/auth_repository.dart';
import 'perform_full_logout_usecase.dart';

class LogoutUseCase {
  final AuthRepository authRepository;
  final PerformFullLogoutUseCase? performFullLogout;

  LogoutUseCase(
    this.authRepository, {
    this.performFullLogout,
  });

  Future<void> execute() async {
    if (performFullLogout != null) {
      await performFullLogout!.execute();
    }
    await authRepository.logout();
  }
}
