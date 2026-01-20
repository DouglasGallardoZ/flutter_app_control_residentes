// lib/infrastructure/providers/face_api.dart
import 'package:dio/dio.dart';

class FaceApi {
  final Dio client;

  FaceApi(this.client);

  Future<bool> validate({
    required String accountId,
    required String capturePath,
  }) async {
    try {
      // Placeholder: integrar endpoint cuando se defina API
      // Por ahora retorna true para testing
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
