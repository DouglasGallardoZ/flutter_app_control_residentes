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

  /// Eliminar un miembro
  Future<void> deleteMember(int memberId);
}
