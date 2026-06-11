import 'dart:typed_data';

/// Puerto para servicios de inscripción facial
abstract class FacialEnrollmentApiPort {
  /// Inscribir datos faciales para residente/miembro
  ///
  /// @param personaId ID de la persona a inscribir
  /// @param imagenesBytes Bytes de las imágenes faciales
  /// @param usuarioCreado Usuario que realiza la inscripción
  /// @return Map con resultado de la inscripción
  Future<Map<String, dynamic>> enrollFacialData({
    required String personaId,
    required List<Uint8List> imagenesBytes,
    String? usuarioCreado,
  });
}
