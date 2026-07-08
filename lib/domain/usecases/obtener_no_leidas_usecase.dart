import '../ports/notificacion_repository_port.dart';

class ObtenerNoLeidasUseCase {
  final NotificacionRepositoryPort _repository;

  ObtenerNoLeidasUseCase(this._repository);

  Future<int> execute(String usuarioId) {
    return _repository.obtenerNoLeidas(usuarioId);
  }
}
