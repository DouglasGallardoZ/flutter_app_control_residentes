import '../ports/member_repository.dart';

class DeleteMemberUseCase {
  final MemberRepository repository;

  DeleteMemberUseCase(this.repository);

  Future<void> call(int memberId, [String motivo = '']) async {
    return await repository.deleteMember(memberId, motivo);
  }
}
