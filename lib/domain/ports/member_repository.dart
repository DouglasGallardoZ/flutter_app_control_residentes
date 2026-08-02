abstract class MemberRepository {
  /// Obtener miembros por ubicación (manzana y villa)
  Future<List<Map<String, dynamic>>> getMembersByLocation({
    required String manzana,
    required String villa,
  });

  /// Desactivar un miembro
  Future<void> deactivateMember({required int memberId, required String reason});

  /// Reactivar un miembro
  Future<void> reactivateMember({required int memberId, required String reason});

  /// Bloquear un miembro (desde rol residente)
  Future<void> bloquearMiembro({required int memberId, required String reason});

  /// Desbloquear un miembro (desde rol residente)
  Future<void> desbloquearMiembro({required int memberId, required String reason});

  /// Eliminar un miembro
  Future<void> deleteMember(int memberId, [String motivo = '']);

  /// Agregar/crear un miembro de familia
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
  });
}
