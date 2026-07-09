import '../entities/estado_solicitud.dart';
import '../ports/solicitud_miembro_repository_port.dart';

class ConsultarEstadoSolicitudUseCase {
  final SolicitudMiembroRepositoryPort _repository;

  ConsultarEstadoSolicitudUseCase(this._repository);

  Future<EstadoSolicitudResponse> execute(
      String identificacion) {
    return _repository
        .consultarEstado(identificacion);
  }
}
