import '../../domain/ports/notificacion_push_handler_port.dart';
import '../providers/fcm_provider.dart';

class NotificacionPushHandlerImpl
    implements NotificacionPushHandlerPort {
  final FcmProvider _provider;

  NotificacionPushHandlerImpl(this._provider);

  @override
  Future<void> inicializar(String usuarioId) =>
      _provider.inicializar(usuarioId);

  @override
  Future<String?> obtenerToken() =>
      _provider.obtenerToken();

  @override
  Stream<String> get onTokenRefresh =>
      _provider.onTokenRefresh;

  @override
  void manejarTapEnNotificacion(
          Map<String, dynamic> data) =>
      _provider
          .manejarTapEnNotificacion(data);

  @override
  void manejarNotificacionEnPrimerPlano(
          Map<String, dynamic> data) =>
      _provider
          .manejarNotificacionEnPrimerPlano(data);
}
