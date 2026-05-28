import 'dart:typed_data';
import 'dart:ui' show Size;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../domain/ports/face_detection_port.dart';
import '../../../domain/entities/detected_face.dart';

class FaceDetectionMobileImpl implements FaceDetectionPort {
  late FaceDetector _faceDetector;

  FaceDetectionMobileImpl() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: false,
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  @override
  Future<List<DetectedFace>> processImage({
    required List<int> bytes,
    required int width,
    required int height,
    required int rotation,
    int? bytesPerRow,
  }) async {
    final inputImage = _buildInputImage(bytes, width, height, rotation,
        bytesPerRow ?? width);
    final faces = await _faceDetector.processImage(inputImage);

    return faces.map((face) {
      return DetectedFace(
        headEulerAngleY: face.headEulerAngleY,
        headEulerAngleZ: face.headEulerAngleZ,
      );
    }).toList();
  }

  InputImage _buildInputImage(
    List<int> bytes,
    int width,
    int height,
    int rotation,
    int bytesPerRow,
  ) {
    final imageRotation = _rotationIntToImageRotation(rotation);

    final metadata = InputImageMetadata(
      size: Size(width.toDouble(), height.toDouble()),
      rotation: imageRotation,
      format: InputImageFormat.nv21,
      bytesPerRow: bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: Uint8List.fromList(bytes),
      metadata: metadata,
    );
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  Future<void> close() async {
    await _faceDetector.close();
  }
}
