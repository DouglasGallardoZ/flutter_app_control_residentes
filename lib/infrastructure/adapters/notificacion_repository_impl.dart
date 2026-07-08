import '../../domain/entities/notificacion_item.dart';
import '../../domain/ports/notificacion_repository_port.dart';
import '../providers/notificacion_api_provider.dart';

class NotificacionRepositoryImpl
    implements NotificacionRepositoryPort {
  final NotificacionApiProvider _apiProvider;

  NotificacionRepositoryImpl(this._apiProvider);

  @override
  Future<List<NotificacionItem>> obtenerNotificaciones(
    String usuarioId, {
    int pagina = 1,
    int tamanoPagina = 20,
  }) async {
    final data = await _apiProvider.obtenerNotificaciones(
      usuarioId: usuarioId,
      pagina: pagina,
      tamanoPagina: tamanoPagina,
    );
    final lista = data['data'] as List? ?? [];
    return lista
        .map((json) =>
            NotificacionItem.fromJson(json))
        .toList();
  }

  @override
  Future<int> obtenerNoLeidas(String usuarioId) async {
    return _apiProvider.obtenerNoLeidas(usuarioId);
  }

  @override
  Future<void> marcarComoLeida(
      String usuarioId, int notificacionId) async {
    await _apiProvider.marcarComoLeida(
        usuarioId, notificacionId);
  }

  @override
  Future<void> marcarTodasComoLeidas(
      String usuarioId) async {
    await _apiProvider
        .marcarTodasComoLeidas(usuarioId);
  }

  @override
  Future<void> eliminarNotificacion(
      String usuarioId, int notificacionId) async {
    await _apiProvider.eliminarNotificacion(
        usuarioId, notificacionId);
  }

  @override
  Future<void> registrarTokenFCM(String usuarioId,
      String token, String plataforma) async {
    await _apiProvider.registrarTokenFCM(
        usuarioId, token, plataforma);
  }
}
