import '../../domain/entities/estado_solicitud.dart';
import '../../domain/entities/solicitud_miembro.dart';
import '../../domain/ports/solicitud_miembro_repository_port.dart';
import '../providers/solicitud_miembro_api_provider.dart';

class SolicitudMiembroRepositoryImpl
    implements SolicitudMiembroRepositoryPort {
  final SolicitudMiembroApiProvider _apiProvider;

  SolicitudMiembroRepositoryImpl(this._apiProvider);

  @override
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
  }) async {
    final data =
        await _apiProvider.solicitarRegistro(
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
    return data['notificacion_id'] ?? 0;
  }

  @override
  Future<EstadoSolicitudResponse>
      consultarEstado(String identificacion) async {
    final data = await _apiProvider
        .consultarEstado(identificacion);
    return EstadoSolicitudResponse.fromJson(
        data);
  }

  @override
  Future<List<SolicitudMiembro>>
      listarSolicitudesPendientes() async {
    final data = await _apiProvider
        .listarSolicitudesPendientes();
    return data
        .map((json) =>
            SolicitudMiembro.fromJson(json))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> aprobarSolicitud(
      int solicitudId) async {
    return _apiProvider.aprobarSolicitud(
        solicitudId);
  }

  @override
  Future<void> rechazarSolicitud(int solicitudId,
      {String? motivo}) async {
    await _apiProvider.rechazarSolicitud(
        solicitudId,
        motivo: motivo);
  }
}
