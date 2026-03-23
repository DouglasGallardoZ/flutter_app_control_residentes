/// Puerto para gestión de miembros de familia
abstract class FamilyMemberApiPort {
  /// Obtener lista de miembros de familia
  ///
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @param searchQuery Término de búsqueda (opcional)
  /// @return Lista de miembros de familia
  Future<List<dynamic>> getFamilyMembers({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  });

  /// Obtener miembros de familia por vivienda
  ///
  /// @param viviendaId ID de la vivienda
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @return Lista de miembros de familia en la vivienda
  Future<List<dynamic>> getFamilyMembersByVivienda({
    required int viviendaId,
    int page = 1,
    int pageSize = 20,
  });

  /// Obtener miembros de familia por ubicación (manzana y villa)
  ///
  /// @param manzana Manzana de la vivienda
  /// @param villa Villa de la vivienda
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @return Lista de miembros de familia en la ubicación
  Future<List<dynamic>> getFamilyMembersByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  });

  /// Agregar miembro de familia a un residente
  ///
  /// @param residenteId ID del residente
  /// @param identificacion Identificación del miembro
  /// @param tipoIdentificacion Tipo de identificación
  /// @param nombres Nombres del miembro
  /// @param apellidos Apellidos del miembro
  /// @param fechaNacimiento Fecha de nacimiento
  /// @param manzana Manzana de la vivienda
  /// @param villa Villa de la vivienda
  /// @param parentesco Parentesco con el residente
  /// @param nacionalidad Nacionalidad (opcional)
  /// @param correo Correo electrónico (opcional)
  /// @param celular Número de celular (opcional)
  /// @param direccionAlternativa Dirección alternativa (opcional)
  /// @param parentescoOtroDesc Descripción si parentesco es "otro" (opcional)
  /// @param usuarioCreado Usuario que crea el miembro
  /// @return Map con resultado de la creación
  Future<Map<String, dynamic>> addFamilyMember({
    required String residenteId,
    required String identificacion,
    required String tipoIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String manzana,
    required String villa,
    required String parentesco,
    String? nacionalidad,
    String? correo,
    String? celular,
    String? direccionAlternativa,
    String? parentescoOtroDesc,
    String? usuarioCreado,
  });

  /// Desactivar un miembro de familia
  ///
  /// @param miembroId ID del miembro
  /// @param reason Motivo de desactivación
  /// @param usuarioActualizado Usuario que realiza la desactivación
  /// @return Map con resultado de la desactivación
  Future<Map<String, dynamic>> deactivateMember(
    int miembroId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  });

  /// Reactivar un miembro de familia
  ///
  /// @param miembroId ID del miembro
  /// @param reason Motivo de reactivación
  /// @param usuarioActualizado Usuario que realiza la reactivación
  /// @return Map con resultado de la reactivación
  Future<Map<String, dynamic>> reactivateMember(
    int miembroId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  });

  /// Eliminar un miembro de familia (soft delete)
  ///
  /// @param miembroId ID del miembro
  /// @param reason Motivo de eliminación
  /// @param usuarioActualizado Usuario que realiza la eliminación
  /// @return Map con resultado de la eliminación
  Future<Map<String, dynamic>> deleteMember(
    int miembroId, {
    String reason = 'Solicitud de eliminación de datos',
    String usuarioActualizado = 'admin_system',
  });
}
