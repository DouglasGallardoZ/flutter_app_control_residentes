import '../ports/vivienda_repository_port.dart';

class CambiarPropietarioViviendaUseCase {
  final ViviendaRepositoryPort _repository;
  CambiarPropietarioViviendaUseCase(this._repository);

  Future<void> execute({
    required int viviendaId,
    required int nuevoPropietarioId,
    required String tipo,
    required String motivo,
  }) {
    return _repository.cambiarPropietario(
      viviendaId: viviendaId,
      nuevoPropietarioId: nuevoPropietarioId,
      tipo: tipo,
      motivo: motivo,
    );
  }
}
