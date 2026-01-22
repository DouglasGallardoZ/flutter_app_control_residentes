import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

class CameraFacialView extends StatefulWidget {
  final CameraController controller;
  final Function(List<Face>)? onFacesDetected;

  const CameraFacialView({
    super.key,
    required this.controller,
    this.onFacesDetected,
  });

  @override
  State<CameraFacialView> createState() => _CameraFacialViewState();
}

class _CameraFacialViewState extends State<CameraFacialView> {
  late FaceDetector _faceDetector;
  List<Face> _detectedFaces = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeFaceDetector();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startImageStream();
    });
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: false,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
  }

  void _startImageStream() {
    widget.controller.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _isProcessing = true;
        _processImage(image);
      }
    });
  }

  Future<void> _processImage(CameraImage image) async {
    if (!mounted) {
      _isProcessing = false;
      return;
    }

    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (mounted) {
        setState(() => _detectedFaces = faces);

        if (widget.onFacesDetected != null && faces.isNotEmpty) {
          widget.onFacesDetected!(faces);
        }
      }
    } catch (e) {
      debugPrint('Error procesando imagen: $e');
    } finally {
      if (mounted) {
        _isProcessing = false;
      }
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final sensorOrientation =
          widget.controller.description.sensorOrientation;
      final imageRotation = _rotationIntToImageRotation(sensorOrientation);

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
    } catch (e) {
      debugPrint('Error al convertir imagen: $e');
      return null;
    }
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
  void dispose() {
    if (widget.controller.value.isStreamingImages) {
      widget.controller.stopImageStream();
    }
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraPreview(widget.controller);
  }
}
