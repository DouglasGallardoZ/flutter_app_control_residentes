import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/ports/camera_port.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_bloc.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_event.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_state.dart';
import '../widgets/facial_capture/facial_capture_view.dart';
import '../widgets/responsive_layout.dart';
import '../../domain/ports/face_detection_port.dart';
import 'credentials_miembro_page.dart';
import '../../injection.dart';

class MemberFacialEnrollmentPage extends StatelessWidget {
  final int personaId;
  final String nombres;
  final String apellidos;
  final String type;
  final String? origen;
  final Object? prospectoCompleto;

  const MemberFacialEnrollmentPage({
    super.key,
    required this.personaId,
    required this.nombres,
    required this.apellidos,
    this.type = 'member',
    this.origen,
    this.prospectoCompleto,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FacialEnrollmentBloc>(
      create: (_) => sl<FacialEnrollmentBloc>(),
      child: _MemberFacialEnrollmentView(
        personaId: personaId,
        nombres: nombres,
        apellidos: apellidos,
        type: type,
        origen: origen,
        prospectoCompleto: prospectoCompleto,
      ),
    );
  }
}

class _MemberFacialEnrollmentView extends StatefulWidget {
  final int personaId;
  final String nombres;
  final String apellidos;
  final String type;
  final String? origen;
  final Object? prospectoCompleto;

  const _MemberFacialEnrollmentView({
    required this.personaId,
    required this.nombres,
    required this.apellidos,
    required this.type,
    this.origen,
    this.prospectoCompleto,
  });

  @override
  State<_MemberFacialEnrollmentView> createState() =>
      _MemberFacialEnrollmentViewState();
}

class _MemberFacialEnrollmentViewState
    extends State<_MemberFacialEnrollmentView> {
  final CameraPort _cameraPort = sl<CameraPort>();
  bool _isCameraReady = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final error = await _cameraPort.initialize();
    if (!mounted) return;
    if (error != null) {
      setState(() => _cameraError = error);
      return;
    }
    setState(() => _isCameraReady = true);
    if (mounted) {
      context.read<FacialEnrollmentBloc>().add(
            EnrollmentStarted(personaId: widget.personaId.toString()),
          );
    }
  }

  void _onFaceCaptured(Uint8List bytes, FaceAngle angle) {
    context.read<FacialEnrollmentBloc>().add(
          FaceCaptured(bytes: bytes, angle: angle),
        );
  }

  @override
  void dispose() {
    _cameraPort.stopImageStream();
    super.dispose();
  }

  Future<void> _mostrarDialogoExito(
      FacialEnrollmentSuccess state) async {
    _cameraPort.stopImageStream();

    if (!mounted) return;

    final continuar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text(
              '¡Validación Facial Exitosa!'),
          content: Text(state.mensaje),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(true),
              child:
                  const Text('Continuar'),
            ),
          ],
        ),
      ),
    );

    if (continuar == true && mounted) {
      await Future.delayed(
          const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CredentialsMiembroPage(
            personaId: widget.personaId,
            nombres: widget.nombres,
            apellidos: widget.apellidos,
          ),
        ),
      );
    }
  }

  Future<void> _mostrarDialogoError(
      FacialEnrollmentError state) async {
    final accion = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text(
              'Error en Captura Facial'),
          content: Text(state.mensaje),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx)
                      .pop('cancelar'),
              child:
                  const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx)
                      .pop('reintentar'),
              child:
                  const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (accion == 'cancelar') {
      Navigator.of(context).pop();
    } else if (accion == 'reintentar') {
      context
          .read<FacialEnrollmentBloc>()
          .add(const EnrollmentResubmit());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FacialEnrollmentBloc, FacialEnrollmentState>(
      listener: (context, state) {
        if (state is FacialEnrollmentSuccess) {
          _mostrarDialogoExito(state);
        } else if (state is FacialEnrollmentError) {
          _mostrarDialogoError(state);
        }
      },
      builder: (context, state) => _buildContent(state),
    );
  }

  Widget _buildContent(FacialEnrollmentState state) {
    if (_cameraError != null) {
      return Center(
        child: Text('Error: $_cameraError',
            textAlign: TextAlign.center),
      );
    }

    if (!_isCameraReady) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FacialEnrollmentSubmitting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('PROCESANDO BIOMETRÍA...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    if (state is FacialEnrollmentSuccess) {
      return const SizedBox.shrink();
    }

    final Map<FaceAngle, Uint8List?> imagenes =
        state is FacialEnrollmentInProgress
            ? state.imagenes
            : <FaceAngle, Uint8List?>{};
    final poseActual = state is FacialEnrollmentInProgress
        ? state.poseActual
        : FaceAngle.front;
    final instruccion = state is FacialEnrollmentInProgress
        ? state.instruccion
        : 'MIRE AL FRENTE';
    final fotosCapturadas =
        imagenes.values.where((i) => i != null).length;
    final hayError = state is FacialEnrollmentError;

    final cameraView = FacialCaptureView(
      controller: _cameraPort.controller!,
      faceDetection: sl<FaceDetectionPort>(),
      onFaceCaptured: _onFaceCaptured,
    );

    final panelDeControl = _EnrollmentSidePanel(
      title: 'Validación Facial',
      subtitle: '${widget.nombres} ${widget.apellidos}',
      imagenes: imagenes,
      poseActual: poseActual,
      instruccion: instruccion,
      fotosCapturadas: fotosCapturadas,
      hayError: hayError,
      onCerrar: () => Navigator.of(context).pop(),
      onReintentar: hayError
          ? () {
              context
                  .read<FacialEnrollmentBloc>()
                  .add(const EnrollmentResubmit());
            }
          : null,
    );

    if (ResponsiveLayout.isDesktop(context)) {
      return _buildDesktopLayout(cameraView, panelDeControl);
    }

    return _buildMobileLayout(
        cameraView, imagenes, poseActual, instruccion,
        fotosCapturadas, hayError);
  }

  Widget _buildDesktopLayout(Widget cameraView, Widget sidePanel) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Validación Facial - ${widget.nombres} ${widget.apellidos}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Row(
        children: [
          Expanded(flex: 3, child: cameraView),
          const VerticalDivider(width: 1),
          SizedBox(width: 320, child: sidePanel),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    Widget cameraView,
    Map<FaceAngle, Uint8List?> imagenes,
    FaceAngle poseActual,
    String instruccion,
    int fotosCapturadas,
    bool hayError,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Validación Facial - ${widget.nombres} ${widget.apellidos}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          cameraView,
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            right: 8,
            child: _buildMobilePoseIndicators(imagenes, poseActual),
          ),
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: _buildMobileInstruction(
                instruccion, fotosCapturadas),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'close_member',
              backgroundColor: Colors.red.shade700,
              mini: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close),
            ),
          ),
          if (hayError)
            Positioned(
              bottom: 20,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'retry_member',
                backgroundColor: Colors.orange,
                mini: true,
                onPressed: () {
                  context
                      .read<FacialEnrollmentBloc>()
                      .add(const EnrollmentResubmit());
                },
                child: const Icon(Icons.refresh),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobilePoseIndicators(
      Map<FaceAngle, Uint8List?> imagenes, FaceAngle poseActual) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: FaceAngle.values.map((angulo) {
        final capturada = imagenes[angulo] != null;
        final esActual = angulo == poseActual;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.55),
                  border: Border.all(
                    color: esActual && !capturada
                        ? Colors.cyanAccent
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: capturada
                      ? const Icon(Icons.check,
                          color: Colors.greenAccent, size: 22)
                      : Icon(_iconoPose(angulo),
                          color: esActual ? Colors.cyanAccent : Colors.white54,
                          size: 20),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _etiquetaPose(angulo),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight:
                      esActual ? FontWeight.bold : FontWeight.normal,
                  shadows: const [
                    Shadow(color: Colors.black, blurRadius: 4)
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileInstruction(
      String instruccion, int fotosCapturadas) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.cyanAccent.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            instruccion,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$fotosCapturadas/3 capturas',
            style: TextStyle(
                color: Colors.cyanAccent.withValues(alpha: 0.9),
                fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _iconoPose(FaceAngle angulo) {
    switch (angulo) {
      case FaceAngle.front:
        return Icons.face;
      case FaceAngle.left:
        return Icons.arrow_back;
      case FaceAngle.right:
        return Icons.arrow_forward;
    }
  }

  String _etiquetaPose(FaceAngle angulo) {
    switch (angulo) {
      case FaceAngle.front:
        return 'FRENTE';
      case FaceAngle.left:
        return 'IZQ.';
      case FaceAngle.right:
        return 'DER.';
    }
  }
}

class _EnrollmentSidePanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Map<FaceAngle, Uint8List?> imagenes;
  final FaceAngle poseActual;
  final String instruccion;
  final int fotosCapturadas;
  final bool hayError;
  final VoidCallback onCerrar;
  final VoidCallback? onReintentar;

  const _EnrollmentSidePanel({
    required this.title,
    required this.subtitle,
    required this.imagenes,
    required this.poseActual,
    required this.instruccion,
    required this.fotosCapturadas,
    required this.hayError,
    required this.onCerrar,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Complete las 3 capturas requeridas',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 32),
              _buildPoseSteps(theme),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      instruccion,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: fotosCapturadas / 3,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$fotosCapturadas de 3 poses capturadas',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (hayError)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ocurrió un error en la captura',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCerrar,
                      icon: const Icon(Icons.close),
                      label: const Text('Salir'),
                    ),
                  ),
                  if (onReintentar != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onReintentar,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoseSteps(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: FaceAngle.values.map((angulo) {
        final capturada = imagenes[angulo] != null;
        final esActual = angulo == poseActual;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: capturada
                    ? Colors.green
                    : (esActual
                        ? Colors.blue.shade100
                        : Colors.grey.shade200),
                border: Border.all(
                  color: esActual ? Colors.blue : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: Center(
                child: capturada
                    ? const Icon(Icons.check, color: Colors.white, size: 30)
                    : Icon(_icono(angulo),
                        size: 28,
                        color: esActual ? Colors.blue : Colors.grey),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _etiqueta(angulo),
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    esActual ? FontWeight.bold : FontWeight.normal,
                color: capturada ? Colors.green : Colors.grey.shade700,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  IconData _icono(FaceAngle a) {
    switch (a) {
      case FaceAngle.front:
        return Icons.face;
      case FaceAngle.left:
        return Icons.arrow_back;
      case FaceAngle.right:
        return Icons.arrow_forward;
    }
  }

  String _etiqueta(FaceAngle a) {
    switch (a) {
      case FaceAngle.front:
        return 'FRENTE';
      case FaceAngle.left:
        return 'IZQUIERDA';
      case FaceAngle.right:
        return 'DERECHA';
    }
  }
}
