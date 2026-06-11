import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../../application/blocs/registro_residente/registro_residente_bloc.dart';
import '../../application/blocs/registro_residente/registro_residente_event.dart';
import '../../application/blocs/facial_verification/facial_verification_bloc.dart';
import '../../application/blocs/facial_verification/facial_verification_event.dart';
import '../../application/blocs/facial_verification/facial_verification_state.dart';
import '../../injection.dart';

class FacialVerificationPage extends StatelessWidget {
  final dynamic prospecto;

  const FacialVerificationPage({super.key, required this.prospecto});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FacialVerificationBloc>(
      create: (_) => sl<FacialVerificationBloc>(),
      child: _FacialVerificationView(prospecto: prospecto),
    );
  }
}

class _FacialVerificationView extends StatefulWidget {
  final dynamic prospecto;

  const _FacialVerificationView({required this.prospecto});

  @override
  State<_FacialVerificationView> createState() =>
      _FacialVerificationViewState();
}

class _FacialVerificationViewState extends State<_FacialVerificationView> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isVerifying = false;
  String? _ultimaFotoPath;

  String get _tipoRegistro {
    if (widget.prospecto is ProspectoMiembro) return 'miembro';
    if (widget.prospecto is ProspectoResidente) {
      return (widget.prospecto as ProspectoResidente).tipoRegistro;
    }
    return 'residente';
  }

  int get _personaId {
    if (widget.prospecto is ProspectoMiembro) {
      return (widget.prospecto as ProspectoMiembro).personaId ?? 0;
    }
    if (widget.prospecto is ProspectoResidente) {
      return (widget.prospecto as ProspectoResidente).personaId ?? 0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        await _cameraController!.dispose();
        _cameraController = null;
      }
    } catch (e) {
      debugPrint('Error cerrando cámara: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay cámara disponible'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al inicializar cámara: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _captureFoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (_isVerifying) return;

    setState(() => _isVerifying = true);

    try {
      final photo = await _cameraController!.takePicture();
      final bytes = await photo.readAsBytes();
      _ultimaFotoPath = photo.path;

      if (mounted) {
        context.read<FacialVerificationBloc>().add(
              VerifyFaceSubmitted(
                personaId: _personaId,
                fotoBytes: Uint8List.fromList(bytes),
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturando foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isVerifying = false);
      }
    }
  }

  void _mostrarResultado({
    required bool exitosa,
    required double distance,
    required String imagePath,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              exitosa ? Icons.check_circle : Icons.cancel,
              color: exitosa ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  exitosa ? 'Verificación Exitosa' : 'Verificación Fallida'),
            ),
          ],
        ),
        content: Text(
          exitosa
              ? 'Tu rostro ha sido verificado correctamente. Procederemos a crear tu cuenta.'
              : 'Tu rostro no coincide. Distancia: ${distance.toStringAsFixed(3)}',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          if (!exitosa)
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() => _isVerifying = false);
              },
              child: const Text('Reintentar'),
            ),
          if (exitosa)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF04345C),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                final routeName = _tipoRegistro == 'miembro'
                    ? '/credentialsMiembro'
                    : '/credentialsResidente';
                Navigator.of(context).pushNamed(
                  routeName,
                  arguments: {
                    'prospecto': widget.prospecto,
                    'imagePath': imagePath,
                  },
                );
              },
              child: const Text('Continuar'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FacialVerificationBloc, FacialVerificationState>(
      listener: (context, state) {
        if (state is FacialVerificationSuccess) {
          setState(() => _isVerifying = false);
          context.read<RegistroResidenteBloc>().add(
                VerificacionFacialCompleta(
                  esValida: state.match,
                  distancia: state.distance,
                ),
              );
          _mostrarResultado(
            exitosa: state.match,
            distance: state.distance,
            imagePath: _ultimaFotoPath ?? '',
          );
        } else if (state is FacialVerificationFailure) {
          setState(() => _isVerifying = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.mensaje}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verificación Facial'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                _isVerifying ? null : () => Navigator.of(context).pop(),
          ),
        ),
        body: _isCameraInitialized
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_cameraController!),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 4),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: FloatingActionButton(
                          heroTag: 'verify_capture',
                          backgroundColor: _isVerifying
                              ? Colors.grey
                              : const Color(0xFF04345C),
                          onPressed:
                              _isVerifying ? null : _captureFoto,
                          child: _isVerifying
                              ? const SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 32),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
