import 'package:dio/dio.dart';
import '../../../domain/ports/qr_management/qr_generation_api_port.dart';

class QrGenerationApiImpl implements QrGenerationApiPort {
  final Dio dio;

  QrGenerationApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> generarQRPropio({
    required int personaId,
    required int duracionHoras,
    required String fechaAcceso,
    String? horaInicio,
  }) async {
    try {
      final data = {
        'duracion_horas': duracionHoras,
        'fecha_acceso': fechaAcceso,
        'usuario_creado': 'flutter_app',
      };
      // Si horaInicio se proporciona, incluirla; si no, servidor usa hora actual
      if (horaInicio != null) {
        data['hora_inicio'] = horaInicio;
      }

      final response = await dio.post(
        '/qr/generar-propio',
        queryParameters: {
          'usuario_id': personaId,
        },
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> generarQRVisita({
    required int personaId,
    required String visitaIdentificacion,
    required String visitaNombres,
    required String visitaApellidos,
    required String motivoVisita,
    required int duracionHoras,
    required String fechaAcceso,
    String? horaInicio,
  }) async {
    try {
      final data = {
        'visita_identificacion': visitaIdentificacion,
        'visita_nombres': visitaNombres,
        'visita_apellidos': visitaApellidos,
        'motivo_visita': motivoVisita,
        'duracion_horas': duracionHoras,
        'fecha_acceso': fechaAcceso,
        'usuario_creado': 'flutter_app',
      };
      // Si horaInicio se proporciona, incluirla; si no, servidor usa hora actual
      if (horaInicio != null) {
        data['hora_inicio'] = horaInicio;
      }

      final response = await dio.post(
        '/qr/generar-visita',
        queryParameters: {
          'usuario_id': personaId,
        },
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
