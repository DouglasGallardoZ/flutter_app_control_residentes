import '../ports/auth_repository.dart';
import '../entities/auth_result.dart';

class SignUpUseCase {
  final AuthRepository authRepository;
  SignUpUseCase(this.authRepository);

  Future<AuthResult> execute(String email, String password) async {
    return await authRepository.signUpWithEmail(email, password);
  }
}
