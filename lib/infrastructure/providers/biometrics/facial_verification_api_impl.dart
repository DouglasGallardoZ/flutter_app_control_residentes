import 'package:dio/dio.dart';
import '../../../domain/ports/biometrics/facial_verification_api_port.dart';

class FacialVerificationApiImpl implements FacialVerificationApiPort {
  final Dio dio;

  FacialVerificationApiImpl(this.dio);

  @override
  Future<Map<String, dynamic>> verificarFacial({
    required int personaId,
    required String fotoPath,
  }) async {
    try {
      final formData = FormData();

      // Agregar persona ID
      formData.fields.add(MapEntry('persona_id', personaId.toString()));

      // Agregar imagen
      final archivo = await MultipartFile.fromFile(
        fotoPath,
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
