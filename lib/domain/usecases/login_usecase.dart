import '../ports/auth_repository.dart';
import '../ports/account_repository.dart';

class LoginUseCase {
  final AuthRepository auth;
  final AccountRepository accounts;

  LoginUseCase(this.auth, this.accounts);

  /// Login con email y password
  /// Retorna información completa del usuario autenticado
  Future<Map<String, dynamic>> call({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Autenticar en Firebase + obtener perfil del API
      final loginResult = await auth.login(
        email: email,
        password: password,
      );

      // 2. Obtener cuenta completa usando el Firebase UID
      final account = await accounts.getById(loginResult['uid']);

      if (account == null) {
        throw Exception('Cuenta no encontrada en la base de datos');
      }

      // 3. Retornar información del usuario enriquecida (normalizada)
      return {
        // Firebase
        'uid': loginResult['uid'],
        'email': loginResult['email'],
        'idToken': loginResult['idToken'],
        // User Data (normalizado para acceso consistente)
        'id': account.personaId,
        'identificacion': account.identificacion,
        'identification': account.identificacion,  // alias
        'dni': account.identificacion,  // alias
        'name': account.nombreCompleto,  // normalizado
        'nombres': account.nombres,
        'apellidos': account.apellidos,
        'nombreCompleto': account.nombreCompleto,
        'rol': account.rol,
        'estado': account.estado,
        'correo': account.correo,
        'email': loginResult['email'],
        'celular': account.celular,
        // Residence
        'residence': '${account.vivienda.manzana}-${account.vivienda.villa}',
        'vivienda': {
          'manzana': account.vivienda.manzana,
          'villa': account.vivienda.villa,
        },
        'parentesco': account.parentesco,
        'fechaCreado': account.fechaCreado.toIso8601String(),
      };
    } catch (e) {
      rethrow;
    }
  }
}
