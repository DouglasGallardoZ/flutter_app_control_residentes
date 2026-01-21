import 'package:dio/dio.dart';

class AdminApi {
  final Dio dio;

  AdminApi(this.dio);

  /// Obtener métricas del dashboard del administrador (MOCK)
  /// Nota: Backend aún no implementa endpoint de métricas
  /// Por ahora retorna datos ficticios para demostración
  Future<Map<String, dynamic>> getAdminMetrics() async {
    try {
      // TODO: Cuando el backend implemente /api/v1/admin/metrics, usar:
      // final response = await dio.get('/admin/metrics');
      // return response.data ?? {};
      
      // Por ahora retornamos datos mock
      return _generateMockMetrics();
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener lista de residentes (usando endpoint documentado)
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
      rethrow;
    }
  }

  /// Obtener lista de miembros de familia (usando endpoint documentado)
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
      rethrow;
    }
  }

  /// Obtener lista de propietarios (usando endpoint documentado)
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
      rethrow;
    }
  }

  /// Cambiar estado de una cuenta (MOCK - endpoint no existe)
  /// Nota: No hay endpoint POST para cambiar estado, se usa bloquear/desbloquear
  Future<void> updateAccountStatus(int personaId, String newStatus) async {
    try {
      // Alternativamente usar bloquear/desbloquear según newStatus
      await Future.delayed(const Duration(milliseconds: 500)); // Simular delay
    } catch (e) {
      rethrow;
    }
  }

  /// Bloquear una cuenta (Endpoint documentado: POST /cuentas/{cuenta_id}/bloquear)
  /// Requiere: usuario_actualizado, motivo, cascada (opcional)
  Future<Map<String, dynamic>> blockAccount(
    int cuentaId,
    String reason, {
    String usuarioActualizado = 'admin_system',
    bool cascada = true,
  }) async {
    try {
      final response = await dio.post(
        '/cuentas/$cuentaId/bloquear',
        data: {
          'usuario_actualizado': usuarioActualizado,
          'motivo': reason,
          'cascada': cascada,
        },
      );
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  /// Desbloquear una cuenta (Endpoint documentado: POST /cuentas/{cuenta_id}/desbloquear)
  /// Requiere: usuario_actualizado, motivo, cascada (opcional)
  Future<Map<String, dynamic>> unblockAccount(
    int cuentaId, {
    String usuarioActualizado = 'admin_system',
    String reason = 'Desbloqueo por solicitud de administrador',
    bool cascada = true,
  }) async {
    try {
      final response = await dio.post(
        '/cuentas/$cuentaId/desbloquear',
        data: {
          'usuario_actualizado': usuarioActualizado,
          'motivo': reason,
          'cascada': cascada,
        },
      );
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar una cuenta (Endpoint documentado: DELETE /cuentas/{cuenta_id})
  /// Soft delete - marca como eliminada
  Future<Map<String, dynamic>> deleteAccount(
    int cuentaId, {
    String usuarioActualizado = 'admin_system',
    String reason = 'Solicitud de eliminación de datos',
  }) async {
    try {
      final response = await dio.delete(
        '/cuentas/$cuentaId',
        data: {
          'motivo': reason,
          'usuario_actualizado': usuarioActualizado,
        },
      );
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalles de una cuenta por Firebase UID
  /// Endpoint documentado: GET /cuentas/perfil/{firebase_uid}
  Future<Map<String, dynamic>> getAccountDetails(int firebaseUid) async {
    try {
      final response = await dio.get('/cuentas/perfil/$firebaseUid');
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  /// Generar datos ficticios para métricas
  /// TODO: Reemplazar con /api/v1/admin/metrics cuando backend lo implemente
  Map<String, dynamic> _generateMockMetrics() {
    return {
      'total_access': 156,
      'successful_access': 150,
      'denied_access': 6,
      'visitors': 12,
      'recent_activity': [
        {
          'person_name': 'María Rodríguez',
          'person_role': 'residente',
          'access_type': 'own',
          'related_person': '',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          'entry_point': 'Entrada Principal',
          'status': 'success',
        },
        {
          'person_name': 'Ana García',
          'person_role': 'visitante',
          'access_type': 'visitor',
          'related_person': 'María Rodríguez',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
          'entry_point': 'Entrada Principal',
          'status': 'success',
        },
        {
          'person_name': 'Juan Rodríguez',
          'person_role': 'residente',
          'access_type': 'own',
          'related_person': '',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
          'entry_point': 'Entrada Lateral',
          'status': 'success',
        },
        {
          'person_name': 'Carlos López',
          'person_role': 'visitante',
          'access_type': 'visitor',
          'related_person': 'Juan Rodríguez',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
          'entry_point': 'Entrada Principal',
          'status': 'denied',
        },
      ],
    };
  }
}
