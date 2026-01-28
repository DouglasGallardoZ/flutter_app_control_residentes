import '../../domain/entities/owner_entity.dart';
import '../../domain/entities/conyuge_entity.dart';
import '../../domain/ports/owner_repository.dart';
import '../../infrastructure/dtos/owner_dto.dart';
import '../../infrastructure/providers/admin_api.dart';
import '../../infrastructure/providers/admin_api_spouse_extension.dart';

class OwnerRepositoryImpl implements OwnerRepository {
  final AdminApi adminApi;

  OwnerRepositoryImpl({required this.adminApi});

  @override
  Future<List<OwnerEntity>> getOwners({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      final response = await adminApi.getOwners(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
      );

      return response
          .map((json) => OwnerDTO.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al cargar propietarios: $e');
    }
  }

  @override
  Future<List<OwnerEntity>> getOwnersByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await adminApi.getOwnersByLocation(
        manzana: manzana,
        villa: villa,
        page: page,
        pageSize: pageSize,
      );

      return response
          .map((json) => OwnerDTO.fromJson(json as Map<String, dynamic>).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Error al cargar propietarios por ubicación: $e');
    }
  }

  @override
  Future<void> blockOwner(int ownerId, String reason) async {
    try {
      await adminApi.blockOwner(
        ownerId,
        reason,
        usuarioActualizado: 'admin_system',
      );
    } catch (e) {
      throw Exception('Error al bloquear propietario: $e');
    }
  }

  @override
  Future<void> unblockOwner(int ownerId, String reason) async {
    try {
      await adminApi.unblockOwner(
        ownerId,
        reason,
        usuarioActualizado: 'admin_system',
      );
    } catch (e) {
      throw Exception('Error al desbloquear propietario: $e');
    }
  }

  @override
  Future<void> deleteOwner(int ownerId) async {
    try {
      await adminApi.deleteOwner(
        ownerId,
        usuarioActualizado: 'admin_system',
        reason: 'Propietario eliminado por administrador',
      );
    } catch (e) {
      throw Exception('Error al eliminar propietario: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOwnerProperties(int ownerId) async {
    try {
      // Obtener usuarios/viviendas del propietario - por ahora retorna lista vacía
      // ya que no existe endpoint específico para propiedades de propietario
      return [];
    } catch (e) {
      throw Exception('Error al cargar propiedades del propietario: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> createOwner({
    required String identificacion,
    required String tipoIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String correo,
    required String celular,
    required String manzana,
    required String villa,
    String? nacionalidad,
    String? direccionAlternativa,
    required String usuarioCreado,
  }) async {
    try {
      final response = await adminApi.createOwner(
        identificacion: identificacion,
        tipoIdentificacion: tipoIdentificacion,
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: fechaNacimiento,
        correo: correo,
        celular: celular,
        manzana: manzana,
        villa: villa,
        nacionalidad: nacionalidad,
        direccionAlternativa: direccionAlternativa,
        usuarioCreado: usuarioCreado,
      );
      return response;
    } catch (e) {
      throw Exception('Error al crear propietario: $e');
    }
  }

  // ========== Spouse Management Methods ==========

  @override
  Future<OwnerWithSpousesEntity> getOwnerWithSpouses(int ownerId) async {
    try {
      final response = await adminApi.getOwnerWithSpouses(ownerId);
      return OwnerWithSpousesEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al cargar propietario con cónyuges: $e');
    }
  }

  @override
  Future<ConyugeEntity> createSpouse({
    required int ownerId,
    required String tipoIdentificacion,
    required String identificacion,
    required String nombre,
    required String apellido,
    required String fechaNacimiento,
    required String nacionalidad,
    required String correo,
    required String celular,
    String? direccionAlternativa,
    required String usuarioCreado,
  }) async {
    try {
      final response = await adminApi.createSpouse(
        ownerId: ownerId,
        tipoIdentificacion: tipoIdentificacion,
        identificacion: identificacion,
        nombre: nombre,
        apellido: apellido,
        fechaNacimiento: fechaNacimiento,
        nacionalidad: nacionalidad,
        correo: correo,
        celular: celular,
        direccionAlternativa: direccionAlternativa,
        usuarioCreado: usuarioCreado,
      );
      return ConyugeEntity.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear cónyuge: $e');
    }
  }

  @override
  Future<List<ConyugeEntity>> getSpousesByOwner(int ownerId) async {
    try {
      final response = await adminApi.getSpousesByOwner(ownerId);
      return response
          .map((json) => ConyugeEntity.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al cargar cónyuges: $e');
    }
  }

  @override
  Future<void> deleteSpouse(int spouseId) async {
    try {
      await adminApi.deleteSpouse(spouseId);
    } catch (e) {
      throw Exception('Error al eliminar cónyuge: $e');
    }
  }

  @override
  Future<void> blockSpouse(int spouseId, bool block) async {
    try {
      await adminApi.blockSpouse(spouseId, block);
    } catch (e) {
      throw Exception('Error al ${block ? 'bloquear' : 'desbloquear'} cónyuge: $e');
    }
  }
}
