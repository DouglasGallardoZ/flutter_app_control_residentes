/// Puerto para gestión de historial de accesos
abstract class AccessHistoryApiPort {
  /// Obtener accesos de una vivienda específica (Residente)
  ///
  /// @param viviendaId ID de la vivienda
  /// @param fechaInicio Fecha de inicio para filtrar (opcional)
  /// @param fechaFin Fecha de fin para filtrar (opcional)
  /// @param tipo Tipo de acceso (opcional)
  /// @param resultado Resultado del acceso (opcional)
  /// @return Map con accesos de la vivienda
  Future<Map<String, dynamic>> getResidenceAccesses({
    required int viviendaId,
    String? fechaInicio,
    String? fechaFin,
    String? tipo,
    String? resultado,
  });

  /// Obtener historial de acceso
  ///
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @param filtro Filtro por tipo de acceso o fecha (opcional)
  /// @return Map con historial de acceso
  Future<Map<String, dynamic>> obtenerHistorial({
    int page = 1,
    int pageSize = 10,
    String? filtro,
  });

  /// Obtener detalles de un acceso específico
  ///
  /// @param accesoId ID del acceso
  /// @return Map con detalles del acceso
  Future<Map<String, dynamic>> obtenerAcceso(int accesoId);

  /// Validar QR de acceso
  ///
  /// @param qrToken Token del QR
  /// @param metodoBiometrico Método biométrico utilizado (opcional)
  /// @return Map con resultado de la validación
  Future<Map<String, dynamic>> validarQR({
    required String qrToken,
    String? metodoBiometrico,
  });
}
