import '../ports/resident_repository.dart';

class CreateResidentUseCase {
  final ResidentRepository residentRepository;

  CreateResidentUseCase(this.residentRepository);

  /// Crear un nuevo residente
  /// Retorna la respuesta del servidor con el persona_id asignado
  Future<Map<String, dynamic>> call({
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
  }) async {
    try {
      final response = await residentRepository.createResident(
        identificacion: identificacion,
        tipoIdentificacion: tipoIdentificacion,
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: fechaNacimiento,
        correo: correo,
        celular: celular,
        manzana: manzana,
        villa: villa,
        nacionalidad: nacionalidad,
        direccionAlternativa: direccionAlternativa,
        docAutorizacionPdf: docAutorizacionPdf,
        usuarioCreado: usuarioCreado,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
