import '../entities/owner_entity.dart';

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

  /// Obtener propiedades de un propietario
  Future<List<Map<String, dynamic>>> getOwnerProperties(int ownerId);
}
