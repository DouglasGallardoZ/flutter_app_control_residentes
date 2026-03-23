/// Puerto para gestión de cuentas de usuario
abstract class AccountManagementApiPort {
  /// Obtener usuario por correo electrónico
  ///
  /// @param correo Correo electrónico del usuario
  /// @return Map con información del usuario
  Future<Map<String, dynamic>> getUserByEmail({
    required String correo,
  });

  /// Obtener usuarios de una vivienda por manzana y villa
  ///
  /// @param manzana Manzana de la vivienda
  /// @param villa Villa de la vivienda
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @return Lista de usuarios en la vivienda
  Future<List<dynamic>> getUsersByVivienda({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  });

  /// Cambiar estado de una cuenta
  ///
  /// @param personaId ID de la persona
  /// @param newStatus Nuevo estado de la cuenta
  /// @return void
  Future<void> updateAccountStatus(int personaId, String newStatus);

  /// Bloquear una cuenta
  ///
  /// @param cuentaId ID de la cuenta
  /// @param reason Motivo de bloqueo
  /// @param usuarioActualizado Usuario que realiza el bloqueo
  /// @param cascada Si se aplica en cascada a cuentas relacionadas
  /// @return Map con resultado del bloqueo
  Future<Map<String, dynamic>> blockAccount(
    int cuentaId,
    String reason, {
    String usuarioActualizado = 'admin_system',
    bool cascada = true,
  });

  /// Desbloquear una cuenta
  ///
  /// @param cuentaId ID de la cuenta
  /// @param reason Motivo de desbloqueo
  /// @param usuarioActualizado Usuario que realiza el desbloqueo
  /// @param cascada Si se aplica en cascada a cuentas relacionadas
  /// @return Map con resultado del desbloqueo
  Future<Map<String, dynamic>> unblockAccount(
    int cuentaId,
    String reason, {
    String usuarioActualizado = 'admin_system',
    bool cascada = true,
  });

  /// Eliminar una cuenta (soft delete)
  ///
  /// @param cuentaId ID de la cuenta
  /// @param reason Motivo de eliminación
  /// @param usuarioActualizado Usuario que realiza la eliminación
  /// @return Map con resultado de la eliminación
  Future<Map<String, dynamic>> deleteAccount(
    int cuentaId, {
    String usuarioActualizado = 'admin_system',
    String reason = 'Solicitud de eliminación de datos',
  });

  /// Obtener detalles de una cuenta por Firebase UID
  ///
  /// @param firebaseUid UID de Firebase de la cuenta
  /// @return Map con detalles de la cuenta
  Future<Map<String, dynamic>> getAccountDetails(int firebaseUid);
}
