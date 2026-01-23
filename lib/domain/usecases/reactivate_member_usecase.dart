import '../ports/member_repository.dart';

class ReactivateMemberUseCase {
  final MemberRepository repository;

  ReactivateMemberUseCase(this.repository);

  Future<void> call(int memberId, String reason) async {
    return await repository.reactivateMember(
      memberId: memberId,
      reason: reason,
    );
  }
}
