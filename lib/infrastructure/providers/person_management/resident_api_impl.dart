import 'package:dio/dio.dart';
import '../../../domain/ports/person_management/resident_api_port.dart';

class ResidentApiImpl implements ResidentApiPort {
  final Dio dio;

  ResidentApiImpl(this.dio);

  @override
  Future<List<dynamic>> getResidents({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      // Endpoint documentado: GET /api/v1/residentes?page=1&page_size=20
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null) 'search': searchQuery,
      };
      final response = await dio.get(
        '/residentes',
        queryParameters: queryParams,
      );
      return response.data ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<List<dynamic>> getResidentsByLocation({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
      };
      final response = await dio.get(
        '/residentes/manzana-villa/$manzana/$villa',
        queryParameters: queryParams,
      );
      return response.data?['residentes'] ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> createResident({
    required String identificacion,
    required String tipoIdentificacion,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String correo,
    required String celular,
    required String manzana,
    required String villa,
    String? nacionalidad,
    String? direccionAlternativa,
    String? docAutorizacionPdf,
    String? usuarioCreado,
  }) async {
    try {
      final requestBody = {
        'identificacion': identificacion,
        'tipo_identificacion': tipoIdentificacion,
        'nombres': nombres,
        'apellidos': apellidos,
        'fecha_nacimiento': fechaNacimiento,
        'correo': correo,
        'celular': celular,
        'manzana': manzana,
        'villa': villa,
        if (nacionalidad != null && nacionalidad.isNotEmpty)
          'nacionalidad': nacionalidad,
        if (direccionAlternativa != null && direccionAlternativa.isNotEmpty)
          'direccion_alternativa': direccionAlternativa,
        if (docAutorizacionPdf != null && docAutorizacionPdf.isNotEmpty)
          'doc_autorizacion_pdf': docAutorizacionPdf,
        'usuario_creado': usuarioCreado ?? 'admin_system',
      };

      final response = await dio.post(
        '/residentes',
        data: requestBody,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> deactivateResident(
    int residenteId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/residentes/$residenteId/desactivar',
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
  Future<Map<String, dynamic>> reactivateResident(
    int residenteId,
    String reason, {
    String usuarioActualizado = 'admin_system',
  }) async {
    try {
      final response = await dio.post(
        '/residentes/$residenteId/reactivar',
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
