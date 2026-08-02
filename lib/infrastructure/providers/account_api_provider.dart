import 'package:dio/dio.dart';
import '../../domain/entities/prospecto_residente.dart';

class AccountApiProvider {
  final Dio dio;

  AccountApiProvider({required this.dio});

  Future<ProspectoResidente> validarProspectoResidente(
      String identificacion) async {
    try {
      final response = await dio.get(
        '/cuentas/prospecto/residente/$identificacion',
      );
      return ProspectoResidente.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(e.response?.data['detail'] ??
            'Prospecto no encontrado');
      } else if (e.response?.statusCode == 409) {
        throw Exception(e.response?.data['detail'] ??
            'Esta persona ya tiene una cuenta creada');
      }
      rethrow;
    }
  }

  Future<ProspectoMiembro> validarProspectoMiembro(
      String identificacion) async {
    try {
      final response = await dio.get(
        '/cuentas/prospecto/miembro/$identificacion',
      );
      return ProspectoMiembro.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception(e.response?.data['detail'] ??
            'Esta persona ya tiene una cuenta creada');
      }
      rethrow;
    }
  }

  Future<CuentaResponse> crearCuentaResidente({
    required int personaId,
    required String firebaseUid,
    required String username,
  }) async {
    try {
      final response = await dio.post(
        '/cuentas/residente/firebase',
        data: {
          'persona_id': personaId,
          'firebase_uid': firebaseUid,
          'username': username,
        },
      );
      return CuentaResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
            e.response?.data['detail'] ?? 'Residente no encontrado');
      } else if (e.response?.statusCode == 409) {
        throw Exception(
            e.response?.data['detail'] ?? 'Cuenta ya existe para este residente');
      } else if (e.response?.statusCode == 400) {
        throw Exception(
            e.response?.data['detail'] ?? 'Persona no es residente activo');
      }
      rethrow;
    }
  }

  Future<CuentaResponse> crearCuentaMiembro({
    required int personaId,
    required String firebaseUid,
    required String username,
  }) async {
    try {
      final response = await dio.post(
        '/cuentas/miembro/firebase',
        data: {
          'persona_id': personaId,
          'firebase_uid': firebaseUid,
          'username': username,
        },
      );
      return CuentaResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception(
            e.response?.data['detail'] ?? 'Miembro no encontrado');
      } else if (e.response?.statusCode == 409) {
        throw Exception(
            e.response?.data['detail'] ?? 'Cuenta ya existe para este miembro');
      } else if (e.response?.statusCode == 400) {
        throw Exception(
            e.response?.data['detail'] ?? 'Persona no es miembro activo');
      }
      rethrow;
    }
  }
}
