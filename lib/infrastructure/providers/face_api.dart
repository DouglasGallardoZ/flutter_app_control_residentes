// lib/data/providers/face_api.dart
import 'http_client.dart';

class FaceApi {
  final HttpClient client;
  FaceApi(this.client);

  Future<bool> validate({required String accountId, required String capturePath}) async {
    // Placeholder: integrar endpoint cuando se defina API
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
