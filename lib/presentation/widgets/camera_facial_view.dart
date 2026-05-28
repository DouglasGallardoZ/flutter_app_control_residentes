import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../../domain/ports/face_detection_port.dart';
import '../../domain/entities/detected_face.dart';

class CameraFacialView extends StatefulWidget {
  final CameraController controller;
  final FaceDetectionPort faceDetection;
  final Function(List<DetectedFace>)? onFacesDetected;

  const CameraFacialView({
    super.key,
    required this.controller,
    required this.faceDetection,
    this.onFacesDetected,
  });

  @override
  State<CameraFacialView> createState() => _CameraFacialViewState();
}

class _CameraFacialViewState extends State<CameraFacialView> {
  List<DetectedFace> _detectedFaces = [];
  bool _isProcessing = false;

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

  List<int>? _convertPlanesToBytes(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      return allBytes.done().buffer.asUint8List();
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
    widget.faceDetection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraPreview(widget.controller);
  }
}
