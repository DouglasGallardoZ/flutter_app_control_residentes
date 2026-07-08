import '../ports/notificacion_repository_port.dart';

class MarcarTodasLeidasUseCase {
  final NotificacionRepositoryPort _repository;

  MarcarTodasLeidasUseCase(this._repository);

  Future<void> execute(String usuarioId) {
    return _repository.marcarTodasComoLeidas(usuarioId);
  }
}
