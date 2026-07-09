import '../ports/solicitud_miembro_repository_port.dart';

class SolicitarRegistroMiembroUseCase {
  final SolicitudMiembroRepositoryPort _repository;

  SolicitarRegistroMiembroUseCase(this._repository);

  Future<int> execute({
    required String identificacionResidente,
    required String manzana,
    required String villa,
    required String identificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String parentesco,
    String? parentescoOtroDesc,
    String? correo,
    String? celular,
  }) {
    return _repository.solicitarRegistro(
      identificacionResidente:
          identificacionResidente,
      manzana: manzana,
      villa: villa,
      identificacion: identificacion,
      nombres: nombres,
      apellidos: apellidos,
      fechaNacimiento: fechaNacimiento,
      parentesco: parentesco,
      parentescoOtroDesc: parentescoOtroDesc,
      correo: correo,
      celular: celular,
    );
  }
}
