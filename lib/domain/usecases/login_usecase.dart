import '../ports/auth_repository.dart';

class LoginUseCase {
  final AuthRepository auth;

  LoginUseCase(this.auth);

  /// Login con email y password
  /// Retorna información completa del usuario autenticado
  Future<Map<String, dynamic>> call({
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
