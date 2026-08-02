import 'package:dio/dio.dart';
import '../../../domain/ports/person_management/owner_api_port.dart';
import '../../../core/api_error_handler.dart';

class OwnerApiImpl implements OwnerApiPort {
  final Dio dio;

  OwnerApiImpl(this.dio);

  @override
  Future<List<dynamic>> getOwners({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      // Endpoint documentado: GET /api/v1/propietarios?page=1&page_size=20
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null) 'search': searchQuery,
      };
      final response = await dio.get(
        '/propietarios',
        queryParameters: queryParams,
      );
      return response.data ?? [];
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  @override
  Future<List<dynamic>> getOwnersByLocation({
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
        '/propietarios/manzana-villa/$manzana/$villa',
        queryParameters: queryParams,
      );
      return response.data?['propietarios'] ?? [];
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  @override
  Future<Map<String, dynamic>> createOwner({
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
    bool fromChangeOwner = false,
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
        'from_change_owner': fromChangeOwner,
      };

      final response = await dio.post(
        '/propietarios',
        data: requestBody,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }

  @override
  Future<Map<String, dynamic>> deactivateOwner(
    int propietarioId,
    String reason,
  ) async {
    try {
      final response = await dio.post(
        '/propietarios/$propietarioId/baja',
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
  Future<Map<String, dynamic>> blockOwner(
    int propietarioId,
    String reason,
  ) async {
    try {
      final response = await dio.post(
        '/propietarios/$propietarioId/baja',
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
  Future<Map<String, dynamic>> unblockOwner(
    int propietarioId,
    String reason,
  ) async {
    try {
      final response = await dio.post(
        '/propietarios/$propietarioId/desbloquear',
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
  Future<Map<String, dynamic>> deleteOwner(
    int propietarioId, {
    String reason = 'Solicitud de eliminación de datos',
  }) async {
    try {
      final response = await dio.delete(
        '/propietarios/$propietarioId',
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
  Future<Map<String, dynamic>> updateOwner({
    required int ownerId,
    String? correo,
    String? celular,
  }) async {
    try {
      final response = await dio.put(
        '/propietarios/$ownerId',
        data: {
          if (correo != null) 'correo': correo,
          if (celular != null) 'celular': celular,
        },
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }


}
