import '../../domain/entities/vivienda_entity.dart';
import '../../domain/entities/villa_detalle_entity.dart';
import '../../domain/ports/vivienda_repository_port.dart';
import '../providers/vivienda_api.dart';

class ViviendaRepositoryImpl
    implements ViviendaRepositoryPort {
  final ViviendaApi _api;

  ViviendaRepositoryImpl(
      {required ViviendaApi api})
      : _api = api;

  @override
  Future<List<ViviendaEntity>> listar({
    int page = 1,
    int pageSize = 20,
    String? manzana,
    String? estado,
  }) async {
    final response = await _api.listar(
      page: page,
      pageSize: pageSize,
      manzana: manzana,
      estado: estado,
    );
    final data =
        response['data'] as List<dynamic>? ??
            [];
    return data
        .map((json) =>
            ViviendaEntity.fromJson(
                json as Map<String,
                    dynamic>))
        .toList();
  }

  @override
  Future<int> total({
    String? manzana,
    String? estado,
  }) async {
    final response = await _api.listar(
      page: 1,
      pageSize: 1,
      manzana: manzana,
      estado: estado,
    );
    return response['total'] as int? ??
        0;
  }

  @override
  Future<bool> hasNextPage({
    int page = 1,
    int pageSize = 20,
    String? manzana,
    String? estado,
  }) async {
    final response = await _api.listar(
      page: page,
      pageSize: pageSize,
      manzana: manzana,
      estado: estado,
    );
    return response['has_next']
            as bool? ??
        false;
  }

  @override
  Future<ViviendaEntity> obtenerPorId(
      int viviendaId) async {
    final json =
        await _api.obtenerPorId(
            viviendaId);
    return ViviendaEntity.fromJson(
        json);
  }

  @override
  Future<ViviendaEntity> crear({
    required String manzana,
    required String villa,
    String estado = 'activo',
    String usuarioCreado =
        'api_system',
  }) async {
    final json = await _api.crear(
        manzana: manzana,
        villa: villa);
    return ViviendaEntity.fromJson(
        json);
  }

  @override
  Future<ViviendaEntity> actualizar({
    required int viviendaId,
    String? manzana,
    String? villa,
    String? estado,
    String usuarioActualizado =
        'api_system',
  }) async {
    final json =
        await _api.actualizar(
      viviendaId: viviendaId,
      manzana: manzana,
      villa: villa,
    );
    return ViviendaEntity.fromJson(
        json);
  }

  @override
  Future<void> cambiarEstado({
    required int viviendaId,
    required String estado,
    String? motivo,
    String usuarioActualizado =
        'api_system',
  }) async {
    await _api.cambiarEstado(
      viviendaId: viviendaId,
      estado: estado,
      motivo: motivo,
    );
  }

  @override
  Future<VillaDetalleEntity> getVillaDetalle(int viviendaId) async {
    final json = await _api.getVillaDetalle(viviendaId);
    return VillaDetalleEntity.fromJson(json);
  }

  @override
  Future<void> cambiarPropietario({
    required int viviendaId,
    required int nuevoPropietarioId,
    required String tipo,
    required String motivo,
  }) async {
    await _api.cambiarPropietario(
      viviendaId: viviendaId,
      nuevoPropietarioId: nuevoPropietarioId,
      tipo: tipo,
      motivo: motivo,
    );
  }
}
