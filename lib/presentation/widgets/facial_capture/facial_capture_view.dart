import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../application/blocs/facial_enrollment/facial_enrollment_event.dart';
import '../../../domain/ports/face_detection_port.dart';
import 'facial_capture_mobile.dart';
import 'facial_capture_web.dart';

class FacialCaptureView extends StatelessWidget {
  final CameraController controller;
  final FaceDetectionPort? faceDetection;
  final void Function(Uint8List bytes, FaceAngle angle) onFaceCaptured;

  const FacialCaptureView({
    super.key,
    required this.controller,
    required this.faceDetection,
    required this.onFaceCaptured,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return FacialCaptureWeb(
        controller: controller,
        onFaceCaptured: onFaceCaptured,
      );
    }
    return FacialCaptureMobile(
      controller: controller,
      faceDetection: faceDetection!,
      onFaceCaptured: onFaceCaptured,
    );
  }
}
