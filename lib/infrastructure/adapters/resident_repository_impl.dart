import '../../domain/ports/resident_repository.dart';
import '../providers/admin_api.dart';
import '../dtos/resident_dto.dart';

class ResidentRepositoryImpl implements ResidentRepository {
  final AdminApi adminApi;

  ResidentRepositoryImpl(this.adminApi);

  @override
  Future<Map<String, dynamic>> createResident({
    required String identificacion,
    required String tipoIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String correo,
    required String celular,
    required String manzana,
    required String villa,
    String? nacionalidad,
    String? direccionAlternativa,
    String? docAutorizacionPdf,
    required String usuarioCreado,
  }) async {
    try {
      final response = await adminApi.createResident(
        identificacion: identificacion,
        tipoIdentificacion: tipoIdentificacion,
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: fechaNacimiento,
        correo: correo,
        celular: celular,
        manzana: manzana,
        villa: villa,
        nacionalidad: nacionalidad,
        direccionAlternativa: direccionAlternativa,
        docAutorizacionPdf: docAutorizacionPdf,
        usuarioCreado: usuarioCreado,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getResidents() async {
    try {
      final response = await adminApi.getResidents();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getResidentsByLocation({
    required String manzana,
    required String villa,
  }) async {
    try {
      final response = await adminApi.getResidentsByLocation(
        manzana: manzana,
        villa: villa,
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deactivateResident({
    required int personaId,
    required String reason,
  }) async {
    try {
      await adminApi.deactivateResident(personaId, reason);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> reactivateResident({
    required int personaId,
    required String reason,
  }) async {
    try {
      await adminApi.reactivateResident(personaId, reason);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteResident(int personaId) async {
    try {
      await adminApi.deleteAccount(personaId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getResidenceAccesses({
    required int viviendaId,
    String? fechaInicio,
    String? fechaFin,
    String? tipo,
    String? resultado,
  }) async {
    try {
      final response = await adminApi.getResidenceAccesses(
        viviendaId: viviendaId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        tipo: tipo,
        resultado: resultado,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
