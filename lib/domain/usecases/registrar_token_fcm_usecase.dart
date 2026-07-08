import '../ports/notificacion_repository_port.dart';

class RegistrarTokenFCMUseCase {
  final NotificacionRepositoryPort _repository;

  RegistrarTokenFCMUseCase(this._repository);

  Future<void> execute(String usuarioId, String token,
      String plataforma) {
    return _repository.registrarTokenFCM(
        usuarioId, token, plataforma);
  }
}
