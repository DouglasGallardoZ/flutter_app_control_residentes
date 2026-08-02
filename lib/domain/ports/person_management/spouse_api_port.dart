/// Puerto para gestión de cónyuges de propietarios
abstract class SpouseApiPort {
  /// Obtener cónyuge de un propietario
  ///
  /// @param propietarioId ID del propietario
  /// @return Map con información del cónyuge o null si no existe
  Future<Map<String, dynamic>?> getSpouseByOwnerId(int propietarioId);

  /// Agregar cónyuge a un propietario
  ///
  /// @param propietarioId ID del propietario
  /// @param identificacion Identificación del cónyuge
  /// @param nombres Nombres del cónyuge
  /// @param apellidos Apellidos del cónyuge
  /// @param fechaNacimiento Fecha de nacimiento
  /// @param correo Correo electrónico (opcional)
  /// @param celular Número de celular (opcional)
  /// @return Map con resultado de la creación
  Future<Map<String, dynamic>> addSpouse({
    required int propietarioId,
    required String identificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    String? tipoIdentificacion,
    String? nacionalidad,
    String? correo,
    String? celular,
    String? direccionAlternativa,
  });

  /// Actualizar información del cónyuge
  ///
  /// @param spouseId ID del cónyuge
  /// @param datos Datos a actualizar
  /// @return Map con resultado de la actualización
  Future<Map<String, dynamic>> updateSpouse(
    int spouseId,
    Map<String, dynamic> datos,
  );

  /// Eliminar cónyuge (disociar del propietario)
  ///
  /// @param spouseId ID del cónyuge
  /// @param reason Motivo de eliminación
  /// @return Map con resultado de la eliminación
  Future<Map<String, dynamic>> deleteSpouse(
    int spouseId, {
    String reason = 'Solicitud de eliminación',
  });
}
