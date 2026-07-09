import '../ports/solicitud_miembro_repository_port.dart';

class RechazarSolicitudMiembroUseCase {
  final SolicitudMiembroRepositoryPort _repository;

  RechazarSolicitudMiembroUseCase(this._repository);

  Future<void> execute(int solicitudId,
      {String? motivo}) {
    return _repository.rechazarSolicitud(solicitudId,
        motivo: motivo);
  }
}
