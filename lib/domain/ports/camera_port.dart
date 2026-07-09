import 'dart:typed_data';
import 'package:camera/camera.dart';

abstract class CameraPort {
  Future<String?> initialize();

  bool get isReady;

  CameraController? get controller;

  Future<void> startImageStream(
      void Function(CameraImage image) onImage);

  Future<void> stopImageStream();

  Future<Uint8List?> takePicture();

  Future<void> dispose();
}
