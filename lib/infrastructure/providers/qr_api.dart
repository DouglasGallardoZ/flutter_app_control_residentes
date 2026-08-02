// lib/infrastructure/providers/qr_api.dart
import 'package:dio/dio.dart';

class QrApi {
  final Dio dio;

  QrApi(this.dio);

  /// Generar QR propio
  Future<Map<String, dynamic>> generarQRPropio({
    required int personaId,
    required int duracionHoras,
    required String fechaAcceso, // YYYY-MM-DD
    String? horaInicio, // HH:MM (opcional - servidor usa hora actual si no se especifica)
  }) async {
    try {
      final data = {
        'duracion_horas': duracionHoras,
        'fecha_acceso': fechaAcceso,
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

  /// Generar QR de visita
  Future<Map<String, dynamic>> generarQRVisita({
    required int personaId,
    required String visitaIdentificacion,
    required String visitaNombres,
    required String visitaApellidos,
    required String motivoVisita,
    required int duracionHoras,
    required String fechaAcceso, // YYYY-MM-DD
    String? horaInicio, // HH:MM (opcional - servidor usa hora actual si no se especifica)
  }) async {
    try {
      final data = {
        'visita_identificacion': visitaIdentificacion,
        'visita_nombres': visitaNombres,
        'visita_apellidos': visitaApellidos,
        'motivo_visita': motivoVisita,
        'duracion_horas': duracionHoras,
        'fecha_acceso': fechaAcceso,
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

  /// Obtener detalles de QR
  Future<Map<String, dynamic>> obtenerQR(int qrId) async {
    try {
      final response = await dio.get('/qr/$qrId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Listar QRs generados
  Future<Map<String, dynamic>> listarQRs({
    int page = 1,
    int pageSize = 10,
    String tipoIngreso = 'all', // propio, visita, all
  }) async {
    try {
      final response = await dio.get('/qr/cuenta/generados', queryParameters: {
        'page': page,
        'page_size': pageSize,
        'tipo_ingreso': tipoIngreso,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
