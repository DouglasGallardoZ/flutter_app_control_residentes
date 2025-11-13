import 'package:flutter/material.dart';
import 'package:guardin/models/user.dart';
import 'package:guardin/services/facial_recognition_service.dart';
import 'package:guardin/services/access_event_service.dart';

class FacialScanScreen extends StatefulWidget {
  final User user;

  const FacialScanScreen({super.key, required this.user});

  @override
  State<FacialScanScreen> createState() => _FacialScanScreenState();
}

class _FacialScanScreenState extends State<FacialScanScreen> with SingleTickerProviderStateMixin {
  final _facialService = FacialRecognitionService();
  final _accessEventService = AccessEventService();

  bool _isScanning = false;
  bool _scanComplete = false;
  bool _scanSuccess = false;
  String _message = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startFacialScan() async {
    if (widget.user.faceImagePath == null || widget.user.faceImagePath!.isEmpty) {
      _showRegisterFaceDialog();
      return;
    }

    setState(() {
      _isScanning = true;
      _scanComplete = false;
      _message = 'Posicione su rostro en el marco...';
    });

    await Future.delayed(Duration(seconds: 1));
    
    if (!mounted) return;
    
    setState(() => _message = 'Escaneando...');

    final result = await _facialService.validateFace(widget.user.faceImagePath);

    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _scanComplete = true;
      _scanSuccess = result['success'] as bool;
      _message = result['message'] as String;
    });

    await _accessEventService.createEvent(
      userId: widget.user.id,
      eventType: 'entrada',
      accessMethod: 'facial',
      isAuthorized: _scanSuccess,
      notes: _message,
    );

    _animationController.stop();
  }

  void _showRegisterFaceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registro facial requerido'),
        content: Text(
          'Debe registrar su rostro antes de usar el reconocimiento facial. '
          '¿Desea registrar su rostro ahora?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _registerFace();
            },
            child: Text('Registrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerFace() async {
    setState(() {
      _isScanning = true;
      _scanComplete = false;
      _message = 'Capturando rostro...';
    });

    await Future.delayed(Duration(seconds: 2));

    final result = await _facialService.captureFace();

    if (!mounted) return;

    if (result['success'] as bool) {
      setState(() {
        _isScanning = false;
        _scanComplete = true;
        _scanSuccess = true;
        _message = '¡Rostro registrado exitosamente!\nYa puede usar el acceso facial.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rostro registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }

    _animationController.stop();
  }

  void _reset() {
    setState(() {
      _scanComplete = false;
      _scanSuccess = false;
      _message = '';
    });
    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reconocimiento facial'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (!_scanComplete) ...[
                Text(
                  'Acceso mediante reconocimiento facial',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  _isScanning
                      ? _message
                      : 'Presione el botón para iniciar el escaneo facial',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: _scanComplete
                      ? _buildResultView()
                      : _buildScanningView(),
                ),
              ),
              SizedBox(height: 40),
              if (!_scanComplete && !_isScanning)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startFacialScan,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.face),
                        SizedBox(width: 12),
                        Text(
                          'Iniciar escaneo',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_scanComplete) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _reset,
                    child: Text(
                      'Intentar nuevamente',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Volver', style: TextStyle(fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        border: Border.all(
          color: _isScanning
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(140),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.face,
            size: 120,
            color: _isScanning
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          if (_isScanning)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: (1 - _animationController.value) * 0.5,
                      ),
                      width: 4,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: (_scanSuccess ? Colors.green : Colors.red).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _scanSuccess ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: _scanSuccess ? Colors.green : Colors.red,
          ),
        ),
        SizedBox(height: 32),
        Text(
          _scanSuccess ? '¡Acceso autorizado!' : 'Acceso denegado',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _scanSuccess ? Colors.green : Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            _message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (_scanSuccess) ...[
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 4),
                Text(
                  widget.user.nombre,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Unidad ${widget.user.unidad}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
