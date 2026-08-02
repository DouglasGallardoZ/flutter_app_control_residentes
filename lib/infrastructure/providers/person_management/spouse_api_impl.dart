import 'package:dio/dio.dart';
import '../../../domain/ports/person_management/spouse_api_port.dart';
import '../../../core/api_error_handler.dart';

class SpouseApiImpl implements SpouseApiPort {
  final Dio dio;

  SpouseApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>?> getSpouseByOwnerId(int propietarioId) async {
    try {
      final response = await dio.get('/propietarios/$propietarioId/conyuge');
      final data = response.data;
      if (data is Map && data.containsKey('conyuge') && data['conyuge'] != null) {
        return data['conyuge'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  @override
  Future<Map<String, dynamic>> addSpouse({
    required int propietarioId,
    required String identificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    String? tipoIdentificacion,
    String? nacionalidad,
    String? correo,
    String? celular,
    String? direccionAlternativa,
    String? usuarioCreado,
  }) async {
    try {
      final body = <String, dynamic>{
        'identificacion': identificacion,
        'tipo_identificacion': tipoIdentificacion ?? 'Cedula',
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'nacionalidad': nacionalidad ?? 'Ecuador',
        'correo': correo ?? '',
        'celular': celular ?? '',
        if (direccionAlternativa != null && direccionAlternativa!.isNotEmpty)
          'direccion_alternativa': direccionAlternativa,
        'usuario_creado': usuarioCreado ?? 'flutter_app',
      };
      final response = await dio.post(
        '/propietarios/$propietarioId/conyuge',
        data: body,
      );
      final data = response.data;
      if (data is Map && data.containsKey('conyuge')) {
        return data['conyuge'] as Map<String, dynamic>;
      }
      return data ?? {};
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  @override
  Future<Map<String, dynamic>> updateSpouse(
    int spouseId,
    Map<String, dynamic> datos, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      datos['usuario_actualizado'] = usuarioActualizado;
      final response = await dio.put(
        '/conyuges/$spouseId',
        data: datos,
      );
      return response.data;
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  @override
  Future<Map<String, dynamic>> deleteSpouse(
    int spouseId, {
    String reason = 'Solicitud de eliminación',
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.delete(
        '/conyuges/$spouseId',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }


}
