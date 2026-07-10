import '../ports/vivienda_repository_port.dart';

class CambiarEstadoViviendaUseCase {
  final ViviendaRepositoryPort _repository;

  CambiarEstadoViviendaUseCase(
      this._repository);

  Future<void> execute({
    required int viviendaId,
    required String estado,
    String? motivo,
  }) {
    return _repository.cambiarEstado(
      viviendaId: viviendaId,
      estado: estado,
      motivo: motivo,
    );
  }
}
