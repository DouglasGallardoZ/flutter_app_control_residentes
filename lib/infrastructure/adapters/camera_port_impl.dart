import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../../domain/ports/camera_port.dart';

class CameraPortImpl implements CameraPort {
  CameraController? _controller;
  bool _isInitializing = false;

  @override
  bool get isReady =>
      _controller != null &&
      _controller!.value.isInitialized;

  @override
  CameraController? get controller => _controller;

  @override
  Future<String?> initialize() async {
    if (isReady) return null;

    if (_isInitializing) {
      for (int i = 0;
          i < 50 && _isInitializing;
          i++) {
        await Future.delayed(
            const Duration(milliseconds: 200));
      }
      if (isReady) return null;
      if (_isInitializing) {
        return 'Timeout esperando inicialización de cámara';
      }
    }

    _isInitializing = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return 'No se encontraron cámaras';
      }

      final front = cameras.firstWhere(
        (c) =>
            c.lensDirection ==
            CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller?.dispose();
      _controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup:
            ImageFormatGroup.nv21,
      );

      await _controller!.initialize();
      debugPrint('[CameraPort] Inicializado OK');
      return null;
    } catch (e) {
      debugPrint('[CameraPort] Error: $e');
      _controller = null;
      return e.toString();
    } finally {
      _isInitializing = false;
    }
  }

  @override
  Future<void> startImageStream(
      void Function(CameraImage image)
          onImage) async {
    if (!isReady) return;
    await _controller!
        .startImageStream(onImage);
  }

  @override
  Future<void> stopImageStream() async {
    if (!isReady) return;
    try {
      await _controller!.stopImageStream();
    } catch (_) {}
  }

  @override
  Future<Uint8List?> takePicture() async {
    if (!isReady) return null;
    try {
      final photo =
          await _controller!.takePicture();
      return await photo.readAsBytes();
    } catch (e) {
      debugPrint(
          '[CameraPort] Error takePicture: $e');
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _controller?.dispose();
    } catch (_) {}
    _controller = null;
    _isInitializing = false;
  }
}
