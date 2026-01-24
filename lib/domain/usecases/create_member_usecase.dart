import '../ports/member_repository.dart';

class CreateMemberUseCase {
  final MemberRepository memberRepository;

  CreateMemberUseCase(this.memberRepository);

  /// Agregar un nuevo miembro de familia a un residente
  /// Retorna la respuesta del servidor con el miembro_id asignado
  Future<Map<String, dynamic>> call({
    required int residenteId,
    required String identificacion,
    required String tipoIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String manzana,
    required String villa,
    required String parentesco,
    String? nacionalidad,
    String? correo,
    String? celular,
    String? direccionAlternativa,
    String? parentescoOtroDesc,
    required String usuarioCreado,
  }) async {
    try {
      final response = await memberRepository.addMember(
        residenteId: residenteId,
        identificacion: identificacion,
        tipoIdentificacion: tipoIdentificacion,
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: fechaNacimiento,
        manzana: manzana,
        villa: villa,
        parentesco: parentesco,
        nacionalidad: nacionalidad,
        correo: correo,
        celular: celular,
        direccionAlternativa: direccionAlternativa,
        parentescoOtroDesc: parentescoOtroDesc,
        usuarioCreado: usuarioCreado,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
