import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class WebCameraHelper {
  html.VideoElement? _video;
  html.MediaStream? _stream;
  final String _viewId =
      'webcam_${DateTime.now().microsecondsSinceEpoch}';
  bool _ready = false;

  bool get isReady => _ready;

  Future<void> initialize() async {
    try {
      _stream = await html.window.navigator.mediaDevices!
          .getUserMedia({'video': {'facingMode': 'user'}});

      _video = html.VideoElement()
        ..srcObject = _stream
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int id) => _video!,
      );

      await _video!.play();
      await Future.delayed(const Duration(milliseconds: 500));
      _ready = true;
    } catch (e) {
      throw Exception(
        'No se pudo acceder a la cámara.\n'
        '1) Usa localhost o HTTPS\n'
        '2) Concede permiso a la cámara\n'
        '3) Cierra otras apps que usen la cámara\n'
        'Error: $e',
      );
    }
  }

  Widget buildPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: HtmlElementView(viewType: _viewId),
    );
  }

  Future<Uint8List> captureFrame() async {
    if (_video == null) throw Exception('Cámara no lista');

    if (_video!.readyState < 2) {
      await _video!.onCanPlay.first;
    }

    final canvas = html.CanvasElement(
      width: _video!.videoWidth,
      height: _video!.videoHeight,
    );

    canvas.style.position = 'absolute';
    canvas.style.top = '-9999px';
    html.document.body?.children.add(canvas);

    canvas.context2D.drawImage(_video!, 0, 0);

    await Future.delayed(const Duration(milliseconds: 50));
    final blob = await canvas.toBlob('image/jpeg', 0.9);
    canvas.remove();

    final completer = Completer<Uint8List>();
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob);
    reader.onLoad.listen((_) {
      completer.complete(reader.result as Uint8List);
    });
    reader.onError.listen((e) {
      completer.completeError(e);
    });
    return completer.future;
  }

  void dispose() {
    _stream?.getTracks().forEach((t) => t.stop());
    _video?.remove();
    _video = null;
    _stream = null;
    _ready = false;
  }
}
