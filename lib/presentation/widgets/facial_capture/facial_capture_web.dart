import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../application/blocs/facial_enrollment/facial_enrollment_event.dart';

class FacialCaptureWeb extends StatefulWidget {
  final CameraController controller;
  final void Function(Uint8List bytes, FaceAngle angle) onFaceCaptured;

  const FacialCaptureWeb({
    required this.controller,
    required this.onFaceCaptured,
  });

  @override
  State<FacialCaptureWeb> createState() => FacialCaptureWebState();
}

class FacialCaptureWebState extends State<FacialCaptureWeb> {
  int _fotosCapturadas = 0;
  bool _capturando = false;

  List<FaceAngle> get _secuenciaAngulos =>
      [FaceAngle.front, FaceAngle.left, FaceAngle.right];

  FaceAngle get _anguloActual => _secuenciaAngulos[_fotosCapturadas];

  String get _instruccion {
    switch (_anguloActual) {
      case FaceAngle.front:
        return 'MIRE AL FRENTE';
      case FaceAngle.left:
        return 'GIRE A LA IZQUIERDA';
      case FaceAngle.right:
        return 'GIRE A LA DERECHA';
    }
  }

  bool get _completo => _fotosCapturadas >= 3;

  Future<void> _onCapturar() async {
    if (_capturando || _completo) return;

    setState(() => _capturando = true);

    try {
      final photo = await widget.controller.takePicture();

      final bytes = await photo.readAsBytes();

      if (mounted) {
        widget.onFaceCaptured(Uint8List.fromList(bytes), _anguloActual);
        setState(() {
          _fotosCapturadas++;
          _capturando = false;
        });
      }
    } catch (e) {
      debugPrint('Error capturando foto: $e');
      if (mounted) {
        setState(() => _capturando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraPreview(widget.controller),
        Positioned(
          bottom: 40,
          left: 16,
          right: 16,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan, width: 2),
                ),
                child: Text(
                  _completo ? 'Captura completa' : _instruccion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'capture_web',
                    backgroundColor: _completo
                        ? Colors.grey
                        : const Color(0xFF04345C),
                    onPressed: _completo || _capturando ? null : _onCapturar,
                    child: _capturando
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Foto ${_fotosCapturadas}/3',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
