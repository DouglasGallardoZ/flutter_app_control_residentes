import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../domain/ports/face_detection_port.dart';
import '../../../domain/entities/detected_face.dart';

class FaceDetectionWebImpl implements FaceDetectionPort {
  final Dio dio;

  FaceDetectionWebImpl({required this.dio});

  @override
  Future<List<DetectedFace>> processImage({
    required List<int> bytes,
    required int width,
    required int height,
    required int rotation,
    int? bytesPerRow,
  }) async {
    try {
      final base64Image = base64Encode(Uint8List.fromList(bytes));

      final response = await dio.post(
        '/detect-face',
        data: {
          'image': base64Image,
          'width': width,
          'height': height,
          'rotation': rotation,
          if (bytesPerRow != null) 'bytes_per_row': bytesPerRow,
        },
      );

      final data = response.data;
      if (data == null || data['faces'] == null) return [];

      final facesList = data['faces'] as List<dynamic>;
      return facesList.map((faceData) {
        return DetectedFace.fromMap(faceData as Map<String, dynamic>);
      }).toList();
    } on DioException {
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> close() async {}
}
