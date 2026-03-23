import 'package:dio/dio.dart';
import '../../../domain/ports/account_management/account_management_api_port.dart';

class AccountManagementApiImpl implements AccountManagementApiPort {
  final Dio dio;

  AccountManagementApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getUserByEmail({
    required String correo,
  }) async {
    try {
      final response = await dio.get(
        '/cuentas/usuario/por-correo/$correo',
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<List<dynamic>> getUsersByVivienda({
    required String manzana,
    required String villa,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dio.get(
        '/cuentas/vivienda/$manzana/$villa/usuarios',
      );
      return response.data?['usuarios'] ?? [];
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<void> updateAccountStatus(int personaId, String newStatus) async {
    try {
      // Alternativamente usar bloquear/desbloquear según newStatus
      await Future.delayed(const Duration(milliseconds: 500)); // Simular delay
    } catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
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
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> unblockAccount(
    int cuentaId,
    String reason, {
    String usuarioActualizado = 'admin_system',
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
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
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
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<Map<String, dynamic>> getAccountDetails(int firebaseUid) async {
    try {
      final response = await dio.get('/cuentas/perfil/$firebaseUid');
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
