import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../domain/ports/biometrics/facial_enrollment_api_port.dart';

class FacialEnrollmentApiImpl implements FacialEnrollmentApiPort {
  final Dio dio;

  FacialEnrollmentApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> enrollFacialData({
    required String personaId,
    required List<Uint8List> imagenesBytes,
    String? usuarioCreado,
  }) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('persona_id', personaId));

      formData.fields
          .add(MapEntry('usuario_creado', usuarioCreado ?? 'flutter_app'));

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
      throw Exception(_extraerMensajeError(e));
    }
  }

  String _extraerMensajeError(dynamic error) {
    if (error is DioException && error.response != null) {
      final data = error.response?.data;
      if (data is Map) {
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
        if (data.containsKey('message')) {
          return data['message'] ?? 'Error desconocido';
        }
      }
      return error.message ?? 'Error en la solicitud';
    }
    return error.toString();
  }
}
