import '../entities/vivienda_entity.dart';
import '../ports/vivienda_repository_port.dart';

class ListarViviendasUseCase {
  final ViviendaRepositoryPort _repository;

  ListarViviendasUseCase(this._repository);

  Future<List<ViviendaEntity>> execute({
    int page = 1,
    int pageSize = 20,
    String? manzana,
    String? estado,
  }) {
    return _repository.listar(
      page: page,
      pageSize: pageSize,
      manzana: manzana,
      estado: estado,
    );
  }
}
