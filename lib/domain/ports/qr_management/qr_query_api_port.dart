/// Puerto para consulta de códigos QR
abstract class QrQueryApiPort {
  /// Obtener detalles de un QR específico
  ///
  /// @param qrId ID del QR
  /// @return Map con detalles del QR
  Future<Map<String, dynamic>> obtenerQR(int qrId);

  /// Listar QRs generados
  ///
  /// @param page Número de página para paginación
  /// @param pageSize Tamaño de página
  /// @param tipoIngreso Tipo de ingreso (propio, visita, all)
  /// @return Map con lista de QRs
  Future<Map<String, dynamic>> listarQRs({
    int page = 1,
    int pageSize = 10,
    String tipoIngreso = 'all',
  });
}
