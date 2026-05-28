import '../ports/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository authRepository;
  GetCurrentUserUseCase(this.authRepository);

  Map<String, dynamic>? execute() {
    return authRepository.currentUser;
  }
}
