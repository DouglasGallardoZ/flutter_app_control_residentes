import '../ports/member_repository.dart';

class DeactivateMemberUseCase {
  final MemberRepository repository;

  DeactivateMemberUseCase(this.repository);

  Future<void> call(int memberId, String reason) async {
    return await repository.deactivateMember(
      memberId: memberId,
      reason: reason,
    );
  }
}
