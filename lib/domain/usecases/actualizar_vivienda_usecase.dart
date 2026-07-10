import '../entities/vivienda_entity.dart';
import '../ports/vivienda_repository_port.dart';

class ActualizarViviendaUseCase {
  final ViviendaRepositoryPort _repository;

  ActualizarViviendaUseCase(
      this._repository);

  Future<ViviendaEntity> execute({
    required int viviendaId,
    String? manzana,
    String? villa,
  }) {
    return _repository.actualizar(
      viviendaId: viviendaId,
      manzana: manzana,
      villa: villa,
    );
  }
}
