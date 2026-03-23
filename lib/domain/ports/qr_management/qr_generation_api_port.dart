/// Puerto para generación de códigos QR
abstract class QrGenerationApiPort {
  /// Generar QR propio
  ///
  /// @param personaId ID de la persona
  /// @param duracionHoras Duración en horas del QR
  /// @param fechaAcceso Fecha de acceso (YYYY-MM-DD)
  /// @param horaInicio Hora de inicio (HH:MM) - opcional, servidor usa hora actual si no se especifica
  /// @return Map con datos del QR generado
  Future<Map<String, dynamic>> generarQRPropio({
    required int personaId,
    required int duracionHoras,
    required String fechaAcceso,
    String? horaInicio,
  });

  /// Generar QR de visita
  ///
  /// @param personaId ID de la persona que genera el QR
  /// @param visitaIdentificacion Identificación del visitante
  /// @param visitaNombres Nombres del visitante
  /// @param visitaApellidos Apellidos del visitante
  /// @param motivoVisita Motivo de la visita
  /// @param duracionHoras Duración en horas del QR
  /// @param fechaAcceso Fecha de acceso (YYYY-MM-DD)
  /// @param horaInicio Hora de inicio (HH:MM) - opcional, servidor usa hora actual si no se especifica
  /// @return Map con datos del QR generado
  Future<Map<String, dynamic>> generarQRVisita({
    required int personaId,
    required String visitaIdentificacion,
    required String visitaNombres,
    required String visitaApellidos,
    required String motivoVisita,
    required int duracionHoras,
    required String fechaAcceso,
    String? horaInicio,
  });
}
