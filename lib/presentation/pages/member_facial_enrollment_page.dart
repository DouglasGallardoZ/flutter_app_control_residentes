import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/detected_face.dart';
import '../../domain/ports/face_detection_port.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_bloc.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_event.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_state.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../widgets/camera_facial_view.dart';
import 'facial_verification_page.dart';
import '../../injection.dart';

class MemberFacialEnrollmentPage extends StatefulWidget {
  final int personaId;
  final String nombres;
  final String apellidos;
  final String? type; // 'member'

  const MemberFacialEnrollmentPage({
    super.key,
    required this.personaId,
    required this.nombres,
    required this.apellidos,
    this.type = 'member',
  });

  @override
  State<MemberFacialEnrollmentPage> createState() =>
      _MemberFacialEnrollmentPageState();
}

class _MemberFacialEnrollmentPageState
    extends State<MemberFacialEnrollmentPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  DateTime? _lastCaptureTime;
  double _currentAngle = 0.0;  // Para mostrar el ángulo en tiempo real

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _disposeCameraIfSuccess() async {
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

  void _onFacesDetected(List<DetectedFace> faces) async {
    if (faces.isEmpty) return;

    // No procesar si el registro fue exitoso o está en error
    final state = context.read<FacialEnrollmentBloc>().state;
    if (state is FacialEnrollmentSuccess || state is FacialEnrollmentError) {
      return;
    }

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
  void dispose() {
    _disposeCameraIfSuccess();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validación Facial - ${widget.nombres} ${widget.apellidos}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocConsumer<FacialEnrollmentBloc, FacialEnrollmentState>(
        listener: (context, state) {
          if (state is FacialEnrollmentSuccess) {
            // Cerrar la cámara cuando el registro es exitoso
            _disposeCameraIfSuccess();
            
            // Mostrar diálogo de éxito
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => WillPopScope(
                onWillPop: () async => false, // Evitar cerrar con back
                child: AlertDialog(
                  title: const Text('¡Validación Facial Exitosa!'),
                  content: Text(state.mensaje),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        // Cerrar el diálogo
                        if (mounted && Navigator.of(dialogContext).canPop()) {
                          Navigator.of(dialogContext).pop();
                        }
                        
                        // Pequeña pausa para actualizar el estado
                        await Future.delayed(const Duration(milliseconds: 100));
                        
                        if (mounted) {
                          // Crear ProspectoMiembro para pasar a facial_verification_page
                          final prospectoMiembro = ProspectoMiembro(
                            existe: true,
                            personaEncontrada: true,
                            personaId: widget.personaId,
                            nombres: widget.nombres,
                            apellidos: widget.apellidos,
                          );
                          
                          // Navegar a facial_verification_page para verificar el rostro
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => FacialVerificationPage(
                                  prospecto: prospectoMiembro,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Continuar'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is FacialEnrollmentError) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: const Text('Error en Captura Facial'),
                  content: Text(state.mensaje),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (mounted && Navigator.of(dialogContext).canPop()) {
                          Navigator.of(dialogContext).pop(); // Cerrar diálogo
                        }
                        // Reintentar
                        context.read<FacialEnrollmentBloc>().add(
                              RetryFacialEnrollment(),
                            );
                      },
                      child: const Text('Reintentar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (mounted && Navigator.of(dialogContext).canPop()) {
                          Navigator.of(dialogContext).pop(); // Cerrar diálogo
                        }
                        
                        // Esperar a que se cierre completamente
                        await Future.delayed(const Duration(milliseconds: 300));
                        
                        if (mounted && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop(); // Volver atrás
                        }
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
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

          // Cuando el registro es exitoso, mostrar un widget vacío
          // El diálogo de éxito se muestra en el listener
          if (state is FacialEnrollmentSuccess) {
            return Container();
          }

          String instruction = 'MIRE AL FRENTE';
          int progress = 0;
          bool showRetryButton = false;

          if (state is FacialEnrollmentInProgress) {
            instruction = state.instruccion;
            progress = state.fotosCapturadas;
          } else if (state is FacialPhotoCaptured) {
            progress = state.fotoNumero;
          } else if (state is FacialEnrollmentError) {
            showRetryButton = true;
          }

          return Stack(
            children: [
              // Vista de cámara
              CameraFacialView(
                controller: _cameraController!,
                faceDetection: sl<FaceDetectionPort>(),
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

              // Botones de acción (cancelar/reintentar)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.red.shade700,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close),
                    ),
                    if (showRetryButton)
                      FloatingActionButton(
                        backgroundColor: Colors.orange,
                        onPressed: () {
                          // Reiniciar captura
                          context.read<FacialEnrollmentBloc>().add(
                                RetryFacialEnrollment(),
                              );
                        },
                        child: const Icon(Icons.refresh),
                      ),
                  ],
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
}
