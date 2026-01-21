import 'package:dio/dio.dart';

class AdminApi {
  final Dio dio;

  AdminApi(this.dio);

  /// Obtener métricas del dashboard del administrador
  Future<Map<String, dynamic>> getAdminMetrics() async {
    try {
      final response = await dio.get('/admin/metrics');
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener lista de residentes
  Future<List<dynamic>> getResidents({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null) 'search': searchQuery,
        if (statusFilter != null) 'status': statusFilter,
      };
      final response = await dio.get(
        '/admin/residentes',
        queryParameters: queryParams,
      );
      return response.data ?? [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener lista de miembros de familia
  Future<List<dynamic>> getFamilyMembers({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null) 'search': searchQuery,
      };
      final response = await dio.get(
        '/admin/miembros-familia',
        queryParameters: queryParams,
      );
      return response.data ?? [];
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener lista de propietarios
  Future<List<dynamic>> getOwners({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null) 'search': searchQuery,
      };
      final response = await dio.get(
        '/admin/propietarios',
        queryParameters: queryParams,
      );
      return response.data ?? [];
    } catch (e) {
      rethrow;
    }
  }

  /// Cambiar estado de una cuenta
  Future<void> updateAccountStatus(int personaId, String newStatus) async {
    try {
      await dio.patch(
        '/admin/cuentas/$personaId/estado',
        data: {'estado': newStatus},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Bloquear una cuenta
  Future<void> blockAccount(int personaId, String reason) async {
    try {
      await dio.post(
        '/admin/cuentas/$personaId/bloquear',
        data: {'razon': reason},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Desbloquear una cuenta
  Future<void> unblockAccount(int personaId) async {
    try {
      await dio.post('/admin/cuentas/$personaId/desbloquear');
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar una cuenta (soft delete)
  Future<void> deleteAccount(int personaId) async {
    try {
      await dio.delete('/admin/cuentas/$personaId');
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalles de una cuenta específica
  Future<Map<String, dynamic>> getAccountDetails(int personaId) async {
    try {
      final response = await dio.get('/admin/cuentas/$personaId');
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }
}
