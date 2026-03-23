/// Puerto para servicios de verificación facial
abstract class FacialVerificationApiPort {
  /// Verificar identidad facial
  ///
  /// @param personaId ID de la persona a verificar
  /// @param fotoPath Ruta de la imagen facial a verificar
  /// @return Map con resultado de la verificación (match, distance, personaId)
  Future<Map<String, dynamic>> verificarFacial({
    required int personaId,
    required String fotoPath,
  });
}
