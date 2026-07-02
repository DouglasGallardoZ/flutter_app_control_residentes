import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../application/blocs/registro_residente/registro_residente_bloc.dart';
import '../../application/blocs/registro_residente/registro_residente_event.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_event.dart';
import '../../application/blocs/facial_verification/facial_verification_bloc.dart';
import '../../application/blocs/facial_verification/facial_verification_event.dart';
import '../../application/blocs/facial_verification/facial_verification_state.dart';
import '../../application/blocs/security_session/security_session_bloc.dart';
import '../../application/blocs/security_session/security_session_event.dart';
import '../widgets/facial_capture/facial_capture_view.dart';
import '../widgets/facial_capture/facial_capture_mobile.dart';
import '../../domain/ports/face_detection_port.dart';
import '../../injection.dart';

enum VerificationMode { createCredentials, unlockApp }

class FacialVerificationPage extends StatelessWidget {
  final dynamic prospecto;
  final VerificationMode mode;

  const FacialVerificationPage({
    super.key,
    required this.prospecto,
    this.mode = VerificationMode.createCredentials,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FacialVerificationBloc>(
      create: (_) => sl<FacialVerificationBloc>()
        ..add(IniciarVerificacionLiveness()),
      child: _FacialVerificationView(prospecto: prospecto, mode: mode),
    );
  }
}

class _FacialVerificationView extends StatefulWidget {
  final dynamic prospecto;
  final VerificationMode mode;

  const _FacialVerificationView({required this.prospecto, required this.mode});

  @override
  State<_FacialVerificationView> createState() =>
      _FacialVerificationViewState();
}

class _FacialVerificationViewState extends State<_FacialVerificationView> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _ultimaFotoPath;
  bool _cameraDisposeInProgress = false;
  bool _isNavigatingAway = false;
  late FacialVerificationBloc _facialVerificationBloc;

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
    _facialVerificationBloc = context.read<FacialVerificationBloc>();

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    _initializeCamera();
  }

  @override
  void dispose() {
    _facialVerificationBloc.add(VerificationCancelada());
    _disposeCamera();
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    if (_cameraDisposeInProgress) return;
    _cameraDisposeInProgress = true;
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        _detenerStreamCamara();
        await _cameraController!.dispose();
      }
    } catch (e) {
      debugPrint('Error cerrando cámara: $e');
    } finally {
      _cameraController = null;
      _isCameraInitialized = false;
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

  Future<void> _enviarFotoAlServidor() async {
    if (_cameraController == null) return;
    try {
      if (!_cameraController!.value.isInitialized) return;
    } catch (_) {
      return;
    }

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
      }
    }
  }

  void _detenerStreamCamara() {
    try {
      if (_cameraController?.value.isStreamingImages == true) {
        _cameraController?.stopImageStream();
      }
    } catch (_) {}
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
                context
                    .read<FacialVerificationBloc>()
                    .add(IniciarVerificacionLiveness());
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

  void _onFrameProcessed(FrameLivenessData data) {
    context.read<FacialVerificationBloc>().add(
          ProcesarFrameCamara(
            eulerX: data.eulerX,
            eulerY: data.eulerY,
            smilingProb: data.smilingProb,
            leftEyeOpenProb: data.leftEyeOpenProb,
            rightEyeOpenProb: data.rightEyeOpenProb,
          ),
        );
  }

  void _onFaceCaptured(Uint8List bytes, FaceAngle angle) {
    // Enrollment callback — no usado en flujo de liveness
  }

  bool _estaAutenticado() {
    try {
      return context.read<AuthBloc>().state is AuthSuccess;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FacialVerificationBloc, FacialVerificationState>(
      listener: (context, state) {
        if (state is LivenessExitoCaptura) {
          _detenerStreamCamara();
          _enviarFotoAlServidor();
        } else if (state is LivenessErrorTimeout) {
          if (!_estaAutenticado()) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context
              .read<FacialVerificationBloc>()
              .add(IniciarVerificacionLiveness());
        } else if (state is FacialVerificationSuccess) {
          if (state.match != true) {
            if (widget.mode == VerificationMode.unlockApp) {
              if (mounted) setState(() => _isNavigatingAway = true);
              _disposeCamera();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) Navigator.of(context).pop(false);
              });
            } else {
              _mostrarResultado(
                exitosa: false,
                distance: state.distance,
                imagePath: _ultimaFotoPath ?? '',
              );
            }
            return;
          }

          if (widget.mode == VerificationMode.unlockApp) {
            context.read<SecuritySessionBloc>().add(UnlockSessionRequested());
            if (mounted) setState(() => _isNavigatingAway = true);
            _disposeCamera();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop(true);
            });
            return;
          }

          _disposeCamera();
          context.read<RegistroResidenteBloc>().add(
                VerificacionFacialCompleta(
                  esValida: true,
                  distancia: state.distance,
                ),
              );
          _mostrarResultado(
            exitosa: true,
            distance: state.distance,
            imagePath: _ultimaFotoPath ?? '',
          );
        } else if (state is FacialVerificationFailure) {
          if (widget.mode == VerificationMode.unlockApp) {
            if (!_estaAutenticado()) return;
            if (mounted) setState(() => _isNavigatingAway = true);
            _disposeCamera();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verificación fallida: ${state.mensaje}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) Navigator.of(context).pop(false);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.mensaje}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context
                .read<FacialVerificationBloc>()
                .add(IniciarVerificacionLiveness());
          }
        }
      },
      builder: (context, state) {
        final livenessProps =
            state is LivenessRetoPresentado ? state : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Verificación Facial'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: _isCameraInitialized
              ? FacialCaptureView(
                  controller: _cameraController!,
                  faceDetection: sl<FaceDetectionPort>(),
                  onFaceCaptured: _onFaceCaptured,
                  onFrameProcessed: livenessProps != null
                      ? _onFrameProcessed
                      : null,
                  instruccionLiveness: livenessProps?.instruccion,
                  indiceReto: livenessProps?.indiceReto,
                  totalRetos: livenessProps?.totalRetos,
                  segundosRestantes: livenessProps?.segundosRestantes,
                  navigatingAway: _isNavigatingAway,
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
