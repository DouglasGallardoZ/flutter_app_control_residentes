import '../entities/notificacion_item.dart';

abstract class NotificacionRepositoryPort {
  Future<List<NotificacionItem>> obtenerNotificaciones(
    String usuarioId, {
    int pagina = 1,
    int tamanoPagina = 20,
  });

  Future<int> obtenerNoLeidas(String usuarioId);

  Future<void> marcarComoLeida(
      String usuarioId, int notificacionId);

  Future<void> marcarTodasComoLeidas(String usuarioId);

  Future<void> eliminarNotificacion(
      String usuarioId, int notificacionId);

  Future<void> registrarTokenFCM(
      String usuarioId, String token, String plataforma);
}
