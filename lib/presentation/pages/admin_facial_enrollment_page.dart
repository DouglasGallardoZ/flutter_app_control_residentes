import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_bloc.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_event.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_state.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/camera_facial_view.dart';

class AdminFacialEnrollmentPage extends StatefulWidget {
  final int personaId;
  final String nombres;
  final String apellidos;

  const AdminFacialEnrollmentPage({
    super.key,
    required this.personaId,
    required this.nombres,
    required this.apellidos,
  });

  @override
  State<AdminFacialEnrollmentPage> createState() =>
      _AdminFacialEnrollmentPageState();
}

class _AdminFacialEnrollmentPageState extends State<AdminFacialEnrollmentPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  DateTime? _lastCaptureTime;
  double _currentAngle = 0.0;  // Para mostrar el ángulo en tiempo real

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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

      // Preferir cámara frontal
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

        // Iniciar el BLoC con el registro facial
        context.read<FacialEnrollmentBloc>().add(
              InitiateFacialEnrollment(personaId: widget.personaId.toString()),
            );
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

  Future<String> _captureImage() async {
    try {
      final image = await _cameraController!.takePicture();
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/facial_enrollment_$timestamp.jpg';
      await File(image.path).copy(path);
      return path;
    } catch (e) {
      debugPrint('Error capturando imagen: $e');
      return '';
    }
  }

  void _onFacesDetected(List<Face> faces) async {
    if (faces.isEmpty) return;

    final face = faces[0];
    final angle = face.headEulerAngleY ?? 0.0;
    
    // Actualizar ángulo en tiempo real
    setState(() {
      _currentAngle = angle;
    });
    
    // Debug: mostrar ángulo en consola
    print('Ángulo detectado: ${angle.toStringAsFixed(2)}°');

    // Throttle para no capturar muy frecuente
    final now = DateTime.now();
    if (_lastCaptureTime != null &&
        now.difference(_lastCaptureTime!).inMilliseconds < 800) {
      return;
    }
    _lastCaptureTime = now;

    // Capturar imagen
    final imagePath = await _captureImage();

    if (imagePath.isNotEmpty && mounted) {
      context.read<FacialEnrollmentBloc>().add(
            FaceDetected(
              eulerAngleY: angle,
              imagePath: imagePath,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Captura Facial - ${widget.nombres} ${widget.apellidos}',
      routeName: '/adminFacialEnrollment',
      showBackButton: true,
      onBackPressed: () {
        Navigator.of(context).pop();
      },
      body: BlocConsumer<FacialEnrollmentBloc, FacialEnrollmentState>(
        listener: (context, state) {
          if (state is FacialEnrollmentSuccess) {
            // Mostrar diálogo de éxito
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                title: const Text('¡Registro Facial Exitoso!'),
                content: Text(state.mensaje),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar diálogo
                      Navigator.of(context).pop(); // Volver atrás
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if (state is FacialEnrollmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (!_isCameraInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FacialEnrollmentSubmitting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'PROCESANDO BIOMETRÍA...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          String instruction = 'MIRE AL FRENTE';
          int progress = 0;

          if (state is FacialEnrollmentInProgress) {
            instruction = state.instruccion;
            progress = state.fotosCapturadas;
          } else if (state is FacialPhotoCaptured) {
            progress = state.fotoNumero;
          }

          return Stack(
            children: [
              // Vista de cámara
              CameraFacialView(
                controller: _cameraController!,
                onFacesDetected: _onFacesDetected,
              ),

              // Barra de progreso (superior)
              Positioned(
                top: 20,
                left: 16,
                right: 16,
                child: _buildProgressBar(progress),
              ),

              // Banner de instrucciones (inferior)
              Positioned(
                bottom: 40,
                left: 16,
                right: 16,
                child: _buildInstructionBanner(instruction),
              ),

              // Contador de fotos
              Positioned(
                top: 80,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Foto ${progress}/3',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ángulo: ${_currentAngle.toStringAsFixed(1)}°',
                        style: TextStyle(
                          color: _currentAngle.abs() < 15
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón de cancelar
              Positioned(
                bottom: 20,
                left: 16,
                child: FloatingActionButton(
                  backgroundColor: Colors.red.shade700,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Barra de progreso con 3 segmentos
  Widget _buildProgressBar(int progress) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index < progress ? Colors.green : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  /// Banner con instrucciones
  Widget _buildInstructionBanner(String instruction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            instruction,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Mantenga el rostro centrado en la pantalla',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
