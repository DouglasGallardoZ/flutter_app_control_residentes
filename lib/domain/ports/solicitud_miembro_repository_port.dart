import '../entities/estado_solicitud.dart';
import '../entities/solicitud_miembro.dart';

abstract class SolicitudMiembroRepositoryPort {
  Future<int> solicitarRegistro({
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
  });

  Future<EstadoSolicitudResponse> consultarEstado(
      String identificacion);

  Future<List<SolicitudMiembro>>
      listarSolicitudesPendientes();

  Future<Map<String, dynamic>> aprobarSolicitud(
      int solicitudId);

  Future<void> rechazarSolicitud(int solicitudId,
      {String? motivo});
}
