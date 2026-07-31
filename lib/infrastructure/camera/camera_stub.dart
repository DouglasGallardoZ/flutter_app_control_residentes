import 'dart:typed_data';
import 'package:flutter/material.dart';

class WebCameraHelper {
  WebCameraHelper();
  bool get isReady => false;
  Future<void> initialize() async {
    throw UnsupportedError('WebCamera no disponible en esta plataforma');
  }
  Future<Uint8List> captureFrame() async {
    throw UnsupportedError('WebCamera no disponible en esta plataforma');
  }
  Widget buildPreview() =>
      const Center(child: Text('Cámara no soportada en esta plataforma'));
  void dispose() {}
}
