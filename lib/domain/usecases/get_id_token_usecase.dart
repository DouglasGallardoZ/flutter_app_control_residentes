import '../ports/auth_repository.dart';

class GetIdTokenUseCase {
  final AuthRepository authRepository;
  GetIdTokenUseCase(this.authRepository);

  Future<String?> execute({bool forceRefresh = false}) async {
    return await authRepository.getIdToken(forceRefresh: forceRefresh);
  }
}
