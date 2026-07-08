import '../ports/notificacion_repository_port.dart';

class EliminarNotificacionUseCase {
  final NotificacionRepositoryPort _repository;

  EliminarNotificacionUseCase(this._repository);

  Future<void> execute(
      String usuarioId, int notificacionId) {
    return _repository.eliminarNotificacion(
        usuarioId, notificacionId);
  }
}
