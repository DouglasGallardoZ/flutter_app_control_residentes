import '../ports/solicitud_miembro_repository_port.dart';
import '../entities/solicitud_miembro.dart';

class ListarSolicitudesPendientesUseCase {
  final SolicitudMiembroRepositoryPort _repository;

  ListarSolicitudesPendientesUseCase(this._repository);

  Future<List<SolicitudMiembro>> execute() {
    return _repository.listarSolicitudesPendientes();
  }
}
