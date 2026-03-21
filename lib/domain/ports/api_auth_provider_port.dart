/// Puerto para operaciones de autenticación con la API del sistema
abstract class ApiAuthProviderPort {
  /// Autentica un usuario con email y contraseña en la API
  /// Retorna: {access_token, usuario_id, username}
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  /// Obtiene el perfil del usuario por Firebase UID
  Future<Map<String, dynamic>> obtenerPerfil(String firebaseUid);

  /// Crea una cuenta de residente vinculada a Firebase
  Future<Map<String, dynamic>> crearCuentaResidente({
    required int personaId,
    required String firebaseUid,
    required String email,
  });

  /// Crea una cuenta de miembro de familia vinculada a Firebase
  Future<Map<String, dynamic>> crearCuentaMiembro({
    required int personaId,
    required String firebaseUid,
    required String email,
  });
}
