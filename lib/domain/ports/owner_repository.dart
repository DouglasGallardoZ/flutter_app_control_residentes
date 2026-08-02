import '../entities/owner_entity.dart';
import '../entities/conyuge_entity.dart';

abstract class OwnerRepository {
  /// Obtener todos los propietarios con paginación
  Future<List<OwnerEntity>> getOwners({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  });

  /// Obtener propietarios por ubicación (manzana, villa)
  Future<List<OwnerEntity>> getOwnersByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  });

  /// Bloquear un propietario
  Future<void> blockOwner(int ownerId, String reason);

  /// Desbloquear un propietario
  Future<void> unblockOwner(int ownerId, String reason);

  /// Eliminar un propietario
  Future<void> deleteOwner(int ownerId);

  /// Actualizar datos de un propietario (correo, celular)
  Future<void> updateOwner({
    required int ownerId,
    String? correo,
    String? celular,
  });

  /// Obtener propiedades de un propietario
  Future<List<Map<String, dynamic>>> getOwnerProperties(int ownerId);

  /// Crear un nuevo propietario
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
    bool fromChangeOwner = false,
  });

  /// Obtener propietario con sus cónyuges
  Future<OwnerWithSpousesEntity> getOwnerWithSpouses(int ownerId);

  /// Crear cónyuge para un propietario
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
  });

  /// Obtener cónyuges de un propietario
  Future<List<ConyugeEntity>> getSpousesByOwner(int ownerId);

  /// Eliminar cónyuge
  Future<void> deleteSpouse(int spouseId);

  /// Bloquear/desbloquear cónyuge
  Future<void> blockSpouse(int spouseId, bool block);
}
