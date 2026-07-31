import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../domain/ports/biometrics/facial_verification_api_port.dart';
import '../../../core/api_error_handler.dart';

class FacialVerificationApiImpl implements FacialVerificationApiPort {
  final Dio dio;

  FacialVerificationApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> verificarFacial({
    required int personaId,
    required Uint8List fotoBytes,
  }) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('persona_id', personaId.toString()));

      final archivo = MultipartFile.fromBytes(
        fotoBytes,
        filename: 'face.jpg',
      );
      formData.files.add(MapEntry('image', archivo));

      final response = await dio.post(
        '/verify',
        data: formData,
      );

      return {
        'match': response.data['match'] ?? false,
        'distance': (response.data['distance'] as num?)?.toDouble() ?? 1.0,
        'personaId': response.data['persona_id'],
      };
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }


}
