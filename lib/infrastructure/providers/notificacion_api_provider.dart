import '../providers/http_client.dart';

class NotificacionApiProvider {
  final ApiHttpClient _cliente;

  NotificacionApiProvider(this._cliente);

  Future<Map<String, dynamic>> obtenerNotificaciones({
    required String usuarioId,
    int pagina = 1,
    int tamanoPagina = 20,
  }) async {
    final respuesta = await _cliente.dio.get(
      '/notificaciones',
      queryParameters: {
        'pagina': pagina,
        'tamano_pagina': tamanoPagina,
      },
    );
    return respuesta.data;
  }

  Future<int> obtenerNoLeidas(String usuarioId) async {
    final respuesta =
        await _cliente.dio.get('/notificaciones/no-leidas');
    return respuesta.data['no_leidas'] ?? 0;
  }

  Future<void> marcarComoLeida(
      String usuarioId, int notificacionId) async {
    await _cliente.dio.put(
        '/notificaciones/$notificacionId/leer');
  }

  Future<void> marcarTodasComoLeidas(
      String usuarioId) async {
    await _cliente.dio.put('/notificaciones/leer-todas');
  }

  Future<void> eliminarNotificacion(
      String usuarioId, int notificacionId) async {
    await _cliente.dio
        .delete('/notificaciones/$notificacionId');
  }

  Future<void> registrarTokenFCM(String usuarioId,
      String token, String plataforma) async {
    await _cliente.dio.post('/notificaciones/token', data: {
      'token_fcm': token,
      'plataforma': plataforma,
    });
  }
}
