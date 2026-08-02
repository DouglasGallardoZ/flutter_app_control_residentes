import 'package:dio/dio.dart';
import '../../../domain/ports/person_management/resident_api_port.dart';
import '../../../core/api_error_handler.dart';

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
      throw Exception(ApiErrorHandler.manejar(e));
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
      throw Exception(ApiErrorHandler.manejar(e));
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
      };

      final response = await dio.post(
        '/residentes',
        data: requestBody,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  @override
  Future<Map<String, dynamic>> deactivateResident(
    int residenteId,
    String reason,
  ) async {
    try {
      final response = await dio.post(
        '/residentes/$residenteId/desactivar',
        data: {
          'motivo': reason,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  @override
  Future<Map<String, dynamic>> reactivateResident(
    int residenteId,
    String reason,
  ) async {
    try {
      final response = await dio.post(
        '/residentes/$residenteId/reactivar',
        data: {
          'motivo': reason,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  @override
  Future<Map<String, dynamic>> deleteResident(
    int residenteId,
    String reason,
  ) async {
    try {
      final response = await dio.delete(
        '/residentes/$residenteId',
        data: {
          'motivo': reason,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }
}
