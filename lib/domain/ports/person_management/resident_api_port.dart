/// Puerto para gestión de residentes
abstract class ResidentApiPort {
  /// Obtener lista de residentes
  ///
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @param searchQuery Término de búsqueda (opcional)
  /// @param statusFilter Filtro por estado (opcional)
  /// @return Lista de residentes
  Future<List<dynamic>> getResidents({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? statusFilter,
  });

  /// Obtener residentes por ubicación (manzana y villa)
  ///
  /// @param manzana Manzana de la vivienda
  /// @param villa Villa de la vivienda
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @return Lista de residentes en la ubicación
  Future<List<dynamic>> getResidentsByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  });

  /// Crear un nuevo residente
  ///
  /// @param identificacion Identificación del residente
  /// @param tipoIdentificacion Tipo de identificación
  /// @param nombres Nombres del residente
  /// @param apellidos Apellidos del residente
  /// @param fechaNacimiento Fecha de nacimiento
  /// @param correo Correo electrónico
  /// @param celular Número de celular
  /// @param manzana Manzana de la vivienda
  /// @param villa Villa de la vivienda
  /// @param nacionalidad Nacionalidad (opcional)
  /// @param direccionAlternativa Dirección alternativa (opcional)
  /// @param docAutorizacionPdf Documento de autorización PDF (opcional)
  /// @return Map con resultado de la creación
  Future<Map<String, dynamic>> createResident({
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
    String? docAutorizacionPdf,
  });

  /// Desactivar un residente
  ///
  /// @param residenteId ID del residente
  /// @param reason Motivo de desactivación
  /// @return Map con resultado de la desactivación
  Future<Map<String, dynamic>> deactivateResident(
    int residenteId,
    String reason,
  );

  /// Reactivar un residente
  ///
  /// @param residenteId ID del residente
  /// @param reason Motivo de reactivación
  /// @return Map con resultado de la reactivación
  Future<Map<String, dynamic>> reactivateResident(
    int residenteId,
    String reason,
  );

  /// Eliminar un residente
  ///
  /// @param residenteId ID del residente
  /// @param reason Motivo de eliminación
  /// @return Map con resultado de la eliminación
  Future<Map<String, dynamic>> deleteResident(
    int residenteId,
    String reason,
  );
}
