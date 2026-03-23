import 'package:dio/dio.dart';
import '../../../domain/ports/biometrics/facial_enrollment_api_port.dart';

class FacialEnrollmentApiImpl implements FacialEnrollmentApiPort {
  final Dio dio;

  FacialEnrollmentApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> enrollFacialData({
    required String personaId,
    required List<String> imagenesRutas,
    String? usuarioCreado,
  }) async {
    try {
      final formData = FormData();

      // Agregar persona ID como persona_id
      formData.fields.add(MapEntry('persona_id', personaId));

      // Agregar usuario_creado para auditoría
      formData.fields
          .add(MapEntry('usuario_creado', usuarioCreado ?? 'flutter_app'));

      // Agregar cada imagen
      for (int i = 0; i < imagenesRutas.length; i++) {
        final archivo = await MultipartFile.fromFile(
          imagenesRutas[i],
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
