import '../../domain/entities/detected_face.dart';

abstract class FaceDetectionPort {
  Future<List<DetectedFace>> processImage({
    required List<int> bytes,
    required int width,
    required int height,
    required int rotation,
    int? bytesPerRow,
  });

  Future<void> close();
}
