import '../entities/vivienda_entity.dart';
import '../entities/villa_detalle_entity.dart';

abstract class ViviendaRepositoryPort {
  Future<List<ViviendaEntity>> listar({
    int page = 1,
    int pageSize = 20,
    String? manzana,
    String? estado,
  });

  Future<int> total({
    String? manzana,
    String? estado,
  });

  Future<bool> hasNextPage({
    int page = 1,
    int pageSize = 20,
    String? manzana,
    String? estado,
  });

  Future<ViviendaEntity> obtenerPorId(
      int viviendaId);

  Future<ViviendaEntity> crear({
    required String manzana,
    required String villa,
    String estado = 'activo',
    String usuarioCreado = 'api_system',
  });

  Future<ViviendaEntity> actualizar({
    required int viviendaId,
    String? manzana,
    String? villa,
    String? estado,
    String usuarioActualizado =
        'api_system',
  });

  Future<void> cambiarEstado({
    required int viviendaId,
    required String estado,
    String? motivo,
    String usuarioActualizado =
        'api_system',
  });

  Future<void> cambiarPropietario({
    required int viviendaId,
    required int nuevoPropietarioId,
    required String tipo,
    required String motivo,
  });

  Future<VillaDetalleEntity> getVillaDetalle(int viviendaId);
}
