import '../ports/notificacion_repository_port.dart';
import '../entities/notificacion_item.dart';

class ObtenerNotificacionesUseCase {
  final NotificacionRepositoryPort _repository;

  ObtenerNotificacionesUseCase(this._repository);

  Future<List<NotificacionItem>> execute(String usuarioId,
      {int pagina = 1}) {
    return _repository.obtenerNotificaciones(usuarioId,
        pagina: pagina);
  }
}
