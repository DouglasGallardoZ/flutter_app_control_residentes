/// Puerto para métricas del dashboard de administrador
abstract class AdminMetricsApiPort {
  /// Obtener métricas del dashboard del administrador
  ///
  /// @param fechaInicio Fecha de inicio para filtrar (opcional)
  /// @param fechaFin Fecha de fin para filtrar (opcional)
  /// @return Map con métricas transformadas
  Future<Map<String, dynamic>> getAdminMetrics({
    String? fechaInicio,
    String? fechaFin,
  });

  /// Obtener historial detallado de accesos del sistema
  ///
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @param fechaInicio Fecha de inicio para filtrar (opcional)
  /// @param fechaFin Fecha de fin para filtrar (opcional)
  /// @param tipo Tipo de acceso (opcional)
  /// @param resultado Resultado del acceso (opcional)
  /// @return Map con historial de accesos
  Future<Map<String, dynamic>> getAccessHistory({
    int page = 1,
    int pageSize = 50,
    String? fechaInicio,
    String? fechaFin,
    String? tipo,
    String? resultado,
  });
}
