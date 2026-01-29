import '../ports/resident_repository.dart';

class GetResidenceAccessesUseCase {
  final ResidentRepository residentRepository;

  GetResidenceAccessesUseCase(this.residentRepository);

  Future<Map<String, dynamic>> call({
    required int viviendaId,
    String? fechaInicio,
    String? fechaFin,
    String? tipo,
    String? resultado,
  }) async {
    return await residentRepository.getResidenceAccesses(
      viviendaId: viviendaId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      tipo: tipo,
      resultado: resultado,
    );
  }
}
