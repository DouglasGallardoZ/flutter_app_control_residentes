import 'package:dio/dio.dart';
import '../providers/http_client.dart';
import '../../core/api_error_handler.dart';

class SolicitudMiembroApiProvider {
  final ApiHttpClient _cliente;

  SolicitudMiembroApiProvider(this._cliente);

  Future<Map<String, dynamic>> solicitarRegistro({
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
    try {
      final body = {
        'identificacion_residente':
            identificacionResidente,
        'manzana': manzana,
        'villa': villa,
        'identificacion': identificacion,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'parentesco': parentesco,
        if (parentescoOtroDesc != null)
          'parentesco_otro_desc':
              parentescoOtroDesc,
        if (correo != null) 'correo': correo,
        if (celular != null) 'celular': celular,
      };

      final respuesta = await _cliente.dio.post(
        '/miembros/solicitar',
        data: body,
      );
      return respuesta.data;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  Future<Map<String, dynamic>> consultarEstado(
      String identificacion) async {
    final respuesta = await _cliente.dio.get(
        '/miembros/solicitudes/estado/$identificacion');
    return respuesta.data;
  }

  Future<List<Map<String, dynamic>>>
      listarSolicitudesPendientes() async {
    try {
      final response = await _cliente.dio.get(
          '/miembros/solicitudes/pendientes');
      final data = response.data;
      return List<Map<String, dynamic>>.from(
          data['solicitudes'] ?? []);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  Future<Map<String, dynamic>> aprobarSolicitud(
      int solicitudId) async {
    try {
      final response = await _cliente.dio.put(
        '/miembros/solicitudes/$solicitudId/aprobar',
        data: {},
      );
      return response.data
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  Future<void> rechazarSolicitud(
      int solicitudId,
      {String? motivo}) async {
    try {
      await _cliente.dio.put(
        '/miembros/solicitudes/$solicitudId/rechazar',
        data: {
          if (motivo != null) 'motivo': motivo,
        },
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }


}
