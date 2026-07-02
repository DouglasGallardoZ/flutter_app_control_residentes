import '../ports/session_cleanup_port.dart';

/// Ejecuta la limpieza completa de sesión en todos los servicios.
/// Delega al puerto SessionCleanupPort para coordinar el cierre
/// de sesión en Firebase, backend, interceptores HTTP y almacenamiento local.
class PerformFullLogoutUseCase {
  final SessionCleanupPort sessionCleanup;

  PerformFullLogoutUseCase({required this.sessionCleanup});

  Future<Map<String, bool>> execute() async {
    return await sessionCleanup.clearAllSessions();
  }
}
