import 'package:dio/dio.dart';
import '../../../domain/ports/person_management/family_member_api_port.dart';

class FamilyMemberApiImpl implements FamilyMemberApiPort {
  final Dio dio;

  FamilyMemberApiImpl(this.dio);

  @override
  Future<List<dynamic>> getFamilyMembers({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      // Endpoint documentado: GET /api/v1/miembros-familia?page=1&page_size=20
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null) 'search': searchQuery,
      };
      final response = await dio.get(
        '/miembros-familia',
        queryParameters: queryParams,
      );
      return response.data ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<List<dynamic>> getFamilyMembersByVivienda({
    required int viviendaId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      final response = await dio.get(
        '/miembros/$viviendaId',
        queryParameters: queryParams,
      );
      return response.data?['miembros'] ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<List<dynamic>> getFamilyMembersByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        '/miembros/manzana-villa/$manzana/$villa',
      );
      return response.data?['miembros'] ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> addFamilyMember({
    required String residenteId,
    required String identificacion,
    required String tipoIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String manzana,
    required String villa,
    required String parentesco,
    String? nacionalidad,
    String? correo,
    String? celular,
    String? direccionAlternativa,
    String? parentescoOtroDesc,
    String? usuarioCreado,
  }) async {
    try {
      final requestBody = {
        'identificacion_residente': residenteId,
        'manzana': manzana,
        'villa': villa,
        'identificacion': identificacion,
        'tipo_identificacion': tipoIdentificacion,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'parentesco': parentesco,
        if (nacionalidad != null && nacionalidad.isNotEmpty)
          'nacionalidad': nacionalidad,
        if (correo != null && correo.isNotEmpty) 'correo': correo,
        if (celular != null && celular.isNotEmpty) 'celular': celular,
        if (direccionAlternativa != null && direccionAlternativa.isNotEmpty)
          'direccion_alternativa': direccionAlternativa,
        if (parentesco == 'otro' &&
            parentescoOtroDesc != null &&
            parentescoOtroDesc.isNotEmpty)
          'parentesco_otro_desc': parentescoOtroDesc,
        'usuario_creado': usuarioCreado ?? 'admin_system',
      };

      final response = await dio.post(
        '/miembros/agregar',
        data: requestBody,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> deactivateMember(
    int miembroId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/miembros/$miembroId/desactivar',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> reactivateMember(
    int miembroId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/miembros/$miembroId/reactivar',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> deleteMember(
    int miembroId, {
    String reason = 'Solicitud de eliminación de datos',
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.delete(
        '/miembros/$miembroId',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Método auxiliar para extraer errores detallados de la respuesta API
  String _extractErrorMessage(dynamic error) {
    if (error is DioException && error.response != null) {
      final data = error.response?.data;
      if (data is Map) {
        // Intenta extraer el field 'detail' primero
        if (data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) return detail;
          if (detail is List && detail.isNotEmpty) {
            final firstItem = detail.first;
            if (firstItem is Map && firstItem.containsKey('msg')) {
              return firstItem['msg'];
            }
          }
        }
        // Si hay 'message', usa eso
        if (data.containsKey('message')) {
          return data['message'] ?? 'Error desconocido';
        }
      }
      return error.message ?? 'Error en la solicitud';
    }
    return error.toString();
  }
}
