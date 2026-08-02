import '../../domain/ports/member_repository.dart';
import '../../domain/ports/person_management/family_member_api_port.dart';
import '../../domain/ports/account_management/account_management_api_port.dart';

class MemberRepositoryImpl implements MemberRepository {
  final FamilyMemberApiPort familyMemberApi;
  final AccountManagementApiPort? accountManagementApi;

  MemberRepositoryImpl({
    required this.familyMemberApi,
    this.accountManagementApi,
  });

  @override
  Future<List<Map<String, dynamic>>> getMembersByLocation({
    required String manzana,
    required String villa,
  }) async {
    final response = await familyMemberApi.getFamilyMembersByLocation(
      manzana: manzana,
      villa: villa,
      page: 1,
      pageSize: 100,
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> deactivateMember(
      {required int memberId, required String reason}) async {
    await familyMemberApi.deactivateMember(memberId, reason);
  }

  @override
  Future<void> reactivateMember(
      {required int memberId, required String reason}) async {
    await familyMemberApi.reactivateMember(memberId, reason);
  }

  @override
  Future<void> bloquearMiembro(
      {required int memberId, required String reason}) async {
    await familyMemberApi.bloquearMiembro(memberId, reason);
  }

  @override
  Future<void> desbloquearMiembro(
      {required int memberId, required String reason}) async {
    await familyMemberApi.desbloquearMiembro(memberId, reason);
  }

  @override
  Future<void> deleteMember(int memberId, [String motivo = '']) async {
    await familyMemberApi.deleteMember(memberId,
        reason: motivo.isNotEmpty ? motivo : 'Eliminación de miembro');
  }

  @override
  Future<Map<String, dynamic>> addMember({
    required String residenteId,
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
    final response = await familyMemberApi.addFamilyMember(
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
  }
}
