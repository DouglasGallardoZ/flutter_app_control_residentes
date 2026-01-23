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

  /// Obtener residente por ID
  // Future<Map<String, dynamic>> getResidentById(String personaId);

  /// Actualizar residente
  // Future<Map<String, dynamic>> updateResident({
  //   required String personaId,
  //   required Map<String, dynamic> data,
  // });

  /// Desactivar residente
  Future<void> deactivateResident({
    required int personaId,
    required String reason,
  });
}
