abstract class NotificacionPushHandlerPort {
  Future<void> inicializar(String usuarioId);
  Future<String?> obtenerToken();
  Stream<String> get onTokenRefresh;
  void manejarTapEnNotificacion(Map<String, dynamic> data);
  void manejarNotificacionEnPrimerPlano(
      Map<String, dynamic> data);
}
