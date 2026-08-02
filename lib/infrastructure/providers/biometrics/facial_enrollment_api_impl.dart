import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../domain/ports/biometrics/facial_enrollment_api_port.dart';
import '../../../core/api_error_handler.dart';

class FacialEnrollmentApiImpl implements FacialEnrollmentApiPort {
  final Dio dio;

  FacialEnrollmentApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> enrollFacialData({
    required String personaId,
    required List<Uint8List> imagenesBytes,
  }) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('persona_id', personaId));

      for (int i = 0; i < imagenesBytes.length; i++) {
        final archivo = MultipartFile.fromBytes(
          imagenesBytes[i],
          filename: 'face_$i.jpg',
        );
        formData.files.add(MapEntry('images', archivo));
      }

      final response = await dio.post(
        '/enroll',
        data: formData,
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(ApiErrorHandler.manejar(e));
    }
  }


}
