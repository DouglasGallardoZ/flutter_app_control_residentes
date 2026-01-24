import '../../domain/ports/member_repository.dart';
import '../providers/admin_api.dart';

class MemberRepositoryImpl implements MemberRepository {
  final AdminApi adminApi;

  MemberRepositoryImpl({required this.adminApi});

  @override
  Future<List<Map<String, dynamic>>> getMembersByLocation({
    required String manzana,
    required String villa,
  }) async {
    final response = await adminApi.getFamilyMembersByLocation(
      manzana: manzana,
      villa: villa,
      page: 1,
      pageSize: 100,
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> deactivateMember({required int memberId, required String reason}) async {
    await adminApi.deactivateMember(memberId, reason);
  }

  @override
  Future<void> reactivateMember({required int memberId, required String reason}) async {
    await adminApi.reactivateMember(memberId, reason);
  }

  @override
  Future<void> deleteMember(int memberId) async {
    await adminApi.deleteAccount(memberId);
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
    final response = await adminApi.addFamilyMember(
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
