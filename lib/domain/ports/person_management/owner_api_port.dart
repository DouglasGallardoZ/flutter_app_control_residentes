/// Puerto para gestión de propietarios
abstract class OwnerApiPort {
  /// Obtener lista de propietarios
  ///
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @param searchQuery Término de búsqueda (opcional)
  /// @return Lista de propietarios
  Future<List<dynamic>> getOwners({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  });

  /// Obtener propietarios por ubicación (manzana y villa)
  ///
  /// @param manzana Manzana de la vivienda
  /// @param villa Villa de la vivienda
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @return Lista de propietarios en la ubicación
  Future<List<dynamic>> getOwnersByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  });

  /// Crear un nuevo propietario
  ///
  /// @param identificacion Identificación del propietario
  /// @param tipoIdentificacion Tipo de identificación
  /// @param nombres Nombres del propietario
  /// @param apellidos Apellidos del propietario
  /// @param fechaNacimiento Fecha de nacimiento
  /// @param correo Correo electrónico
  /// @param celular Número de celular
  /// @param manzana Manzana de la vivienda
  /// @param villa Villa de la vivienda
  /// @param nacionalidad Nacionalidad (opcional)
  /// @param direccionAlternativa Dirección alternativa (opcional)
  /// @param usuarioCreado Usuario que crea el propietario
  /// @return Map con resultado de la creación
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

  /// Dar de baja a un propietario
  ///
  /// @param propietarioId ID del propietario
  /// @param reason Motivo de baja
  /// @return Map con resultado de la baja
  Future<Map<String, dynamic>> deactivateOwner(
    int propietarioId,
    String reason,
  );

  /// Bloquear un propietario
  ///
  /// @param propietarioId ID del propietario
  /// @param reason Motivo de bloqueo
  /// @return Map con resultado del bloqueo
  Future<Map<String, dynamic>> blockOwner(
    int propietarioId,
    String reason,
  );

  /// Desbloquear un propietario
  ///
  /// @param propietarioId ID del propietario
  /// @param reason Motivo de desbloqueo
  /// @return Map con resultado del desbloqueo
  Future<Map<String, dynamic>> unblockOwner(
    int propietarioId,
    String reason,
  );

  /// Eliminar un propietario (soft delete)
  ///
  /// @param propietarioId ID del propietario
  /// @param reason Motivo de eliminación
  /// @return Map con resultado de la eliminación
  Future<Map<String, dynamic>> deleteOwner(
    int propietarioId, {
    String reason = 'Solicitud de eliminación de datos',
  });

  Future<Map<String, dynamic>> updateOwner({
    required int ownerId,
    String? correo,
    String? celular,
  });
}
