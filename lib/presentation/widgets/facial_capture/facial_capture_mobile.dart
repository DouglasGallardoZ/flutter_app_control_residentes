import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../application/blocs/facial_enrollment/facial_enrollment_event.dart';
import '../../../../domain/ports/face_detection_port.dart';
import '../../../../domain/entities/detected_face.dart';

class FacialCaptureMobile extends StatefulWidget {
  final CameraController controller;
  final FaceDetectionPort faceDetection;
  final void Function(Uint8List bytes, FaceAngle angle) onFaceCaptured;

  const FacialCaptureMobile({
    required this.controller,
    required this.faceDetection,
    required this.onFaceCaptured,
  });

  @override
  State<FacialCaptureMobile> createState() => FacialCaptureMobileState();
}

class FacialCaptureMobileState extends State<FacialCaptureMobile> {
  bool _isProcessing = false;
  DateTime? _lastCaptureTime;

  FaceAngle _clasificarAngulo(double eulerAngleY) {
    if (eulerAngleY.abs() < 15) return FaceAngle.front;
    if (eulerAngleY > 15) return FaceAngle.left;
    if (eulerAngleY < -15) return FaceAngle.right;
    return FaceAngle.front;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startImageStream();
    });
  }

  void _startImageStream() {
    widget.controller.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _isProcessing = true;
        _processCameraImage(image);
      }
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!mounted) {
      _isProcessing = false;
      return;
    }

    try {
      final bytes = _convertPlanesToBytes(image);
      if (bytes == null) {
        _isProcessing = false;
        return;
      }

      final rotation = widget.controller.description.sensorOrientation;

      final faces = await widget.faceDetection.processImage(
        bytes: bytes,
        width: image.width,
        height: image.height,
        rotation: rotation,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      if (!mounted) {
        _isProcessing = false;
        return;
      }

      if (faces.isEmpty) {
        _isProcessing = false;
        return;
      }

      final face = faces[0];
      final angle = face.headEulerAngleY ?? 0.0;
      final faceAngle = _clasificarAngulo(angle);

      final now = DateTime.now();
      if (_lastCaptureTime != null &&
          now.difference(_lastCaptureTime!).inMilliseconds < 800) {
        _isProcessing = false;
        return;
      }
      _lastCaptureTime = now;

      final fotoBytes = await _captureBytes();

      if (fotoBytes != null && mounted) {
        widget.onFaceCaptured(fotoBytes, faceAngle);
      }
    } catch (e) {
      debugPrint('Error en detección facial: $e');
    } finally {
      if (mounted) {
        _isProcessing = false;
      }
    }
  }

  Future<Uint8List?> _captureBytes() async {
    try {
      final image = await widget.controller.takePicture();
      return await image.readAsBytes();
    } catch (e) {
      debugPrint('Error capturando imagen: $e');
      return null;
    }
  }

  List<int>? _convertPlanesToBytes(CameraImage image) {
    try {
      final bytesBuilder = BytesBuilder(copy: false);
      for (final Plane plane in image.planes) {
        bytesBuilder.add(plane.bytes);
      }
      return bytesBuilder.toBytes();
    } catch (e) {
      debugPrint('Error al convertir planos de imagen: $e');
      return null;
    }
  }

  @override
  void dispose() {
    if (widget.controller.value.isStreamingImages) {
      widget.controller.stopImageStream();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraPreview(widget.controller);
  }
}
