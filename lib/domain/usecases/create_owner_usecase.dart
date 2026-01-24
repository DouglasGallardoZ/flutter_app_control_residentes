import '../ports/owner_repository.dart';

class CreateOwnerUseCase {
  final OwnerRepository ownerRepository;

  CreateOwnerUseCase(this.ownerRepository);

  /// Crear un nuevo propietario
  /// Retorna la respuesta del servidor con el persona_id, propietario_id y residente_id asignados
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
    required String usuarioCreado,
  }) async {
    try {
      final response = await ownerRepository.createOwner(
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
        usuarioCreado: usuarioCreado,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
