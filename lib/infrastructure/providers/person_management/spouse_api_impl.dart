import 'package:dio/dio.dart';
import '../../../domain/ports/person_management/spouse_api_port.dart';

class SpouseApiImpl implements SpouseApiPort {
  final Dio dio;

  SpouseApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>?> getSpouseByOwnerId(int propietarioId) async {
    try {
      final response = await dio.get('/propietarios/$propietarioId/conyuge');
      return response.data;
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> addSpouse({
    required int propietarioId,
    required String identificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    String? correo,
    String? celular,
    String? usuarioCreado,
  }) async {
    try {
      final spouseData = {
        'identificacion': identificacion,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        if (correo != null) 'correo': correo,
        if (celular != null) 'celular': celular,
        if (usuarioCreado != null) 'usuario_creado': usuarioCreado,
      };
      final response = await dio.post(
        '/propietarios/$propietarioId/conyuge',
        data: spouseData,
      );
      return response.data;
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
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
      throw Exception(_extractErrorMessage(e));
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
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException && error.response != null) {
      final data = error.response?.data;
      if (data is Map) {
        if (data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) return detail;
          if (detail is List && detail.isNotEmpty) {
            final firstItem = detail.first;
            if (firstItem is Map && firstItem.containsKey('msg')) {
              return firstItem['msg'] as String;
            }
          }
        }
        if (data.containsKey('message')) {
          return data['message'] as String;
        }
        if (data.containsKey('error')) {
          return data['error'] as String;
        }
      }
      return error.message ?? 'Error desconocido';
    }
    return error.toString();
  }
}
