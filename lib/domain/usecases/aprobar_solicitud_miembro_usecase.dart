import '../ports/solicitud_miembro_repository_port.dart';

class AprobarSolicitudMiembroUseCase {
  final SolicitudMiembroRepositoryPort _repository;

  AprobarSolicitudMiembroUseCase(this._repository);

  Future<Map<String, dynamic>> execute(
      int solicitudId) {
    return _repository.aprobarSolicitud(solicitudId);
  }
}
