import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../application/blocs/facial_enrollment/facial_enrollment_event.dart';
import '../../../../domain/ports/face_detection_port.dart';
import '../../../../domain/entities/detected_face.dart';

class FacialCaptureMobile extends StatefulWidget {
  final CameraController controller;
  final FaceDetectionPort faceDetection;
  final void Function(Uint8List bytes, FaceAngle angle) onFaceCaptured;
  final void Function(FrameLivenessData data)? onFrameProcessed;
  final String? instruccionLiveness;
  final int? indiceReto;
  final int? totalRetos;
  final int? segundosRestantes;
  final bool navigatingAway;

  const FacialCaptureMobile({
    required this.controller,
    required this.faceDetection,
    required this.onFaceCaptured,
    this.onFrameProcessed,
    this.instruccionLiveness,
    this.indiceReto,
    this.totalRetos,
    this.segundosRestantes,
    this.navigatingAway = false,
  });

  @override
  State<FacialCaptureMobile> createState() => FacialCaptureMobileState();
}

class FrameLivenessData {
  final double eulerX;
  final double eulerY;
  final double smilingProb;
  final double leftEyeOpenProb;
  final double rightEyeOpenProb;

  const FrameLivenessData({
    required this.eulerX,
    required this.eulerY,
    required this.smilingProb,
    required this.leftEyeOpenProb,
    required this.rightEyeOpenProb,
  });
}

class FacialCaptureMobileState extends State<FacialCaptureMobile> {
  bool _isProcessing = false;
  DateTime? _lastCaptureTime;
  DateTime? _lastFrameDispatch;
  bool _isDisposing = false;
  bool _isNavigatingAway = false;

  static const _throttleCapturaMs = 800;
  static const _throttleFrameMs = 100;

  FaceAngle _clasificarAngulo(double eulerAngleY) {
    if (eulerAngleY.abs() < 15) return FaceAngle.front;
    if (eulerAngleY > 15) return FaceAngle.left;
    if (eulerAngleY < -15) return FaceAngle.right;
    return FaceAngle.front;
  }

  bool get _modoLiveness => widget.onFrameProcessed != null;

  bool _isDisposed() {
    try {
      return !widget.controller.value.isInitialized;
    } catch (_) {
      return true;
    }
  }

  @override
  void didUpdateWidget(FacialCaptureMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigatingAway && !_isNavigatingAway) {
      setState(() => _isNavigatingAway = true);
    }
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
      if (!_isProcessing && !_isDisposing) {
        _isProcessing = true;
        _processCameraImage(image);
      }
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (!mounted || _isDisposing) {
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

      if (_modoLiveness) {
        _despacharFrameLiveness(face);
        _isProcessing = false;
        return;
      }

      final angle = face.headEulerAngleY ?? 0.0;
      final faceAngle = _clasificarAngulo(angle);

      final now = DateTime.now();
      if (_lastCaptureTime != null &&
          now.difference(_lastCaptureTime!).inMilliseconds <
              _throttleCapturaMs) {
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
      if (mounted && !_isDisposing) {
        _isProcessing = false;
      }
    }
  }

  void _despacharFrameLiveness(DetectedFace face) {
    if (_isDisposing) return;
    final now = DateTime.now();
    if (_lastFrameDispatch != null &&
        now.difference(_lastFrameDispatch!).inMilliseconds <
            _throttleFrameMs) {
      return;
    }
    _lastFrameDispatch = now;

    final data = FrameLivenessData(
      eulerX: face.headEulerAngleX ?? 0.0,
      eulerY: face.headEulerAngleY ?? 0.0,
      smilingProb: face.smilingProbability ?? 0.0,
      leftEyeOpenProb: face.leftEyeOpenProbability ?? 0.0,
      rightEyeOpenProb: face.rightEyeOpenProbability ?? 0.0,
    );

    widget.onFrameProcessed!(data);
  }

  Future<Uint8List?> _captureBytes() async {
    if (_isDisposing) return null;
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
    _isDisposing = true;

    if (widget.controller.value.isStreamingImages) {
      widget.controller.stopImageStream().catchError((_) {});
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposing || !mounted || _isDisposed()) {
      return const SizedBox.shrink();
    }

    final preview = _buildCameraPreview();

    if (_modoLiveness) {
      return Stack(
        children: [
          preview,
          if (widget.instruccionLiveness != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: _buildBannerLiveness(context),
            ),
        ],
      );
    }
    return preview;
  }

  Widget _buildCameraPreview() {
    if (_isNavigatingAway || _isDisposing) {
      return const SizedBox.shrink();
    }
    try {
      if (!widget.controller.value.isInitialized) {
        return const SizedBox.shrink();
      }
      return CameraPreview(widget.controller);
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBannerLiveness(BuildContext context) {
    final reto = widget.indiceReto != null && widget.totalRetos != null
        ? 'RETO ${widget.indiceReto! + 1}/${widget.totalRetos}'
        : '';
    final tiempo = widget.segundosRestantes != null
        ? '${widget.segundosRestantes}s'
        : '';
    final instruccion = widget.instruccionLiveness ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.cyanAccent.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reto.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                reto,
                style: TextStyle(
                  color: Colors.cyanAccent.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            instruccion,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (tiempo.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.segundosRestantes != null
                    ? widget.segundosRestantes! / 5
                    : 0,
                minHeight: 6,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  (widget.segundosRestantes ?? 0) > 2
                      ? Colors.cyanAccent
                      : Colors.orangeAccent,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tiempo: $tiempo',
              style: TextStyle(
                color: (widget.segundosRestantes ?? 0) > 2
                    ? Colors.white70
                    : Colors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
