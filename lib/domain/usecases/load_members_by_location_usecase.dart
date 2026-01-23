import '../ports/member_repository.dart';

class LoadMembersByLocationUseCase {
  final MemberRepository repository;

  LoadMembersByLocationUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call({
    required String manzana,
    required String villa,
  }) async {
    return await repository.getMembersByLocation(
      manzana: manzana,
      villa: villa,
    );
  }
}
