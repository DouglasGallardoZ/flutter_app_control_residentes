/// Puerto para limpieza centralizada de sesión.
/// Coordina el cierre de sesión en todos los servicios:
/// Firebase Auth, backend API, interceptores HTTP, y almacenamiento local.
abstract class SessionCleanupPort {
  /// Ejecuta la limpieza completa de sesión en todos los servicios registrados.
  /// Captura errores por paso sin detener el proceso.
  /// Retorna un mapa con el resultado de cada paso para debugging.
  Future<Map<String, bool>> clearAllSessions();
}
