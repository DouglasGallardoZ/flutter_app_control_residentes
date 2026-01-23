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
}
