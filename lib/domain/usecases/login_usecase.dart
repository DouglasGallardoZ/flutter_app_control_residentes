import '../ports/auth_repository.dart';
import '../entities/auth_session.dart';

class LoginUseCase {
  final AuthRepository auth;

  LoginUseCase(this.auth);

  /// Login con email y password
  /// Retorna información completa del usuario autenticado
  Future<AuthSession> call({
    required String email,
    required String password,
  }) async {
    try {
      // Autenticar en Firebase y obtener perfil desde API
      final loginResult = await auth.login(
        email: email,
        password: password,
      );

      // Retornar información del usuario
      return loginResult;
    } catch (e) {
      rethrow;
    }
  }
}
