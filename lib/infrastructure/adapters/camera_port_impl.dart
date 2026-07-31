import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../../domain/ports/camera_port.dart';
import '../camera/camera_factory.dart';

class CameraPortImpl implements CameraPort {
  CameraController? _controller;
  WebCameraHelper? _webCamera;
  bool _isInitializing = false;

  @override
  bool get isReady => kIsWeb
      ? (_webCamera?.isReady ?? false)
      : (_controller != null && _controller!.value.isInitialized);

  @override
  CameraController? get controller => _controller;

  @override
  Future<String?> initialize() async {
    if (isReady) return null;

    if (_isInitializing) {
      for (int i = 0; i < 50 && _isInitializing; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      if (isReady) return null;
      if (_isInitializing) {
        return 'Timeout esperando inicialización de cámara';
      }
    }

    _isInitializing = true;
    try {
      if (kIsWeb) {
        _webCamera = WebCameraHelper();
        await _webCamera!.initialize();
        debugPrint('[CameraPort] Web inicializado OK');
        return null;
      }

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
      void Function(CameraImage image) onImage) async {
    if (kIsWeb) return; // No soportado en web
    if (!isReady) return;
    await _controller!.startImageStream(onImage);
  }

  @override
  Future<void> stopImageStream() async {
    if (kIsWeb) return;
    if (!isReady) return;
    try {
      await _controller!.stopImageStream();
    } catch (_) {}
  }

  @override
  Future<Uint8List?> takePicture() async {
    if (kIsWeb) {
      if (_webCamera == null || !_webCamera!.isReady) return null;
      try {
        return await _webCamera!.captureFrame();
      } catch (e) {
        debugPrint('[CameraPort] Error takePicture web: $e');
        return null;
      }
    }
    if (!isReady) return null;
    try {
      final photo = await _controller!.takePicture();
      return await photo.readAsBytes();
    } catch (e) {
      debugPrint('[CameraPort] Error takePicture: $e');
      return null;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      _webCamera?.dispose();
      _webCamera = null;
      await _controller?.dispose();
    } catch (_) {}
    _controller = null;
    _isInitializing = false;
  }
}
