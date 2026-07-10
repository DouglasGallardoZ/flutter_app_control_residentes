import '../entities/vivienda_entity.dart';
import '../ports/vivienda_repository_port.dart';

class CrearViviendaUseCase {
  final ViviendaRepositoryPort _repository;

  CrearViviendaUseCase(this._repository);

  Future<ViviendaEntity> execute({
    required String manzana,
    required String villa,
  }) {
    return _repository.crear(
        manzana: manzana, villa: villa);
  }
}
