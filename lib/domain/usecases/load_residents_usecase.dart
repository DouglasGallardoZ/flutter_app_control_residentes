import '../ports/resident_repository.dart';

class LoadResidentsUseCase {
  final ResidentRepository residentRepository;
  LoadResidentsUseCase(this.residentRepository);

  Future<List<Map<String, dynamic>>> execute() async {
    return await residentRepository.getResidents();
  }
}
