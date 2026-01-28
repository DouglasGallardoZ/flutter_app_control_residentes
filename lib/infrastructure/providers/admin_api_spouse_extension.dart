import 'package:dio/dio.dart';
import 'admin_api.dart';

/// Extensión para AdminApi que maneja operaciones de cónyuges
extension AdminApiSpouseExtension on AdminApi {
  /// Extrae mensaje de error de DioException
  String _extractSpouseErrorMessage(dynamic error) {
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

  /// Obtener propietario con sus cónyuges
  Future<Map<String, dynamic>> getOwnerWithSpouses(int ownerId) async {
    try {
      final response = await dio.get('/api/owners/$ownerId/with-spouses');
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractSpouseErrorMessage(e));
    }
  }

  /// Crear cónyuge para un propietario
  Future<Map<String, dynamic>> createSpouse({
    required int ownerId,
    required String tipoIdentificacion,
    required String identificacion,
    required String nombre,
    required String apellido,
    required String fechaNacimiento,
    required String nacionalidad,
    required String correo,
    required String celular,
    String? direccionAlternativa,
    required String usuarioCreado,
  }) async {
    try {
      final response = await dio.post(
        '/propietarios/$ownerId/conyuge',
        data: {
          'tipo_identificacion': tipoIdentificacion.toLowerCase(),
          'identificacion': identificacion,
          'nombres': nombre,
          'apellidos': apellido,
          'fecha_nacimiento': fechaNacimiento,
          'nacionalidad': nacionalidad,
          'correo': correo,
          'celular': celular,
          if (direccionAlternativa?.isNotEmpty ?? false)
            'direccion_alternativa': direccionAlternativa,
          'usuario_creado': usuarioCreado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractSpouseErrorMessage(e));
    }
  }

  /// Obtener cónyuges de un propietario
  Future<List<dynamic>> getSpousesByOwner(int ownerId) async {
    try {
      final response = await dio.get('/api/owners/$ownerId/spouses');
      return response.data is List ? response.data : [];
    } catch (e) {
      throw Exception(_extractSpouseErrorMessage(e));
    }
  }

  /// Eliminar cónyuge
  Future<void> deleteSpouse(int spouseId) async {
    try {
      await dio.delete('/api/spouses/$spouseId');
    } catch (e) {
      throw Exception(_extractSpouseErrorMessage(e));
    }
  }

  /// Bloquear o desbloquear cónyuge
  Future<void> blockSpouse(int spouseId, bool block) async {
    try {
      await dio.patch(
        '/api/spouses/$spouseId/status',
        data: {
          'estado': block ? 'bloqueado' : 'activo',
        },
      );
    } catch (e) {
      throw Exception(_extractSpouseErrorMessage(e));
    }
  }
}
