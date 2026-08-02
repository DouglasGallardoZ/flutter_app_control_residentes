// Domain Port para gestionar residentes
abstract class ResidentRepository {
  /// Crear un nuevo residente
  /// Retorna el response del servidor con persona_id
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
    required String usuarioCreado,
  });

  /// Obtener lista de residentes
  Future<List<Map<String, dynamic>>> getResidents();

  /// Obtener residentes por ubicación (manzana, villa)
  Future<List<Map<String, dynamic>>> getResidentsByLocation({
    required String manzana,
    required String villa,
  });

  /// Desactivar residente
  Future<void> deactivateResident({
    required int personaId,
    required String reason,
  });

  /// Reactivar residente
  Future<void> reactivateResident({
    required int personaId,
    required String reason,
  });

  /// Eliminar residente
  Future<void> deleteResident(int personaId, String motivo);

  /// Obtener accesos de una vivienda
  Future<Map<String, dynamic>> getResidenceAccesses({
    required int viviendaId,
    String? fechaInicio,
    String? fechaFin,
    String? tipo,
    String? resultado,
  });
}
