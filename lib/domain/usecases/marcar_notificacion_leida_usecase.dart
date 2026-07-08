import '../ports/notificacion_repository_port.dart';

class MarcarNotificacionLeidaUseCase {
  final NotificacionRepositoryPort _repository;

  MarcarNotificacionLeidaUseCase(this._repository);

  Future<void> execute(
      String usuarioId, int notificacionId) {
    return _repository.marcarComoLeida(
        usuarioId, notificacionId);
  }
}
