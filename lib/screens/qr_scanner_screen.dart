import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:guardin/services/visit_service.dart';
import 'package:guardin/services/user_service.dart';
import 'package:guardin/services/access_event_service.dart';
import 'package:intl/intl.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final _visitService = VisitService();
  final _userService = UserService();
  final _accessEventService = AccessEventService();

  bool _isProcessing = false;
  bool _scanComplete = false;
  bool _isAuthorized = false;
  String _resultMessage = '';
  String _visitorName = '';
  String _additionalInfo = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleQRCode(String qrCode) async {
    if (_isProcessing || _scanComplete) return;

    setState(() {
      _isProcessing = true;
    });

    await _controller.stop();

    try {
      final visit = await _visitService.getVisitByQrCode(qrCode);
      
      if (visit != null) {
        final resident = await _userService.getUserById(visit.residentId);
        
        final now = DateTime.now();
        final visitDateTime = visit.visitDate;
        final timeDifference = visitDateTime.difference(now).inHours.abs();

        if (visit.status == 'cancelada') {
          _setResult(
            authorized: false,
            message: 'Acceso denegado',
            visitorName: visit.visitorName,
            additionalInfo: 'Esta visita ha sido cancelada',
          );
        } else if (timeDifference > 24) {
          _setResult(
            authorized: false,
            message: 'Acceso denegado',
            visitorName: visit.visitorName,
            additionalInfo: 'La visita está fuera del rango permitido',
          );
        } else {
          _setResult(
            authorized: true,
            message: '¡Acceso autorizado!',
            visitorName: visit.visitorName,
            additionalInfo: 'Visitante de ${resident?.nombre ?? "Desconocido"} - Unidad ${resident?.unidad ?? "N/A"}\n'
                '${DateFormat("dd/MM/yyyy HH:mm").format(visit.visitDate)}',
          );

          await _visitService.updateVisitStatus(visit.id, 'completada');
        }

        await _accessEventService.createEvent(
          visitId: visit.id,
          eventType: 'entrada',
          accessMethod: 'qr',
          isAuthorized: _isAuthorized,
          notes: '$_resultMessage - ${visit.visitorName}',
        );
      } else {
        final user = (await _userService.getAllUsers())
            .where((u) => u.qrCode == qrCode)
            .firstOrNull;

        if (user != null) {
          _setResult(
            authorized: true,
            message: '¡Acceso autorizado!',
            visitorName: user.nombre,
            additionalInfo: 'Residente - Unidad ${user.unidad}',
          );

          await _accessEventService.createEvent(
            userId: user.id,
            eventType: 'entrada',
            accessMethod: 'qr',
            isAuthorized: true,
            notes: 'Acceso de residente con QR personal',
          );
        } else {
          _setResult(
            authorized: false,
            message: 'Acceso denegado',
            visitorName: 'Desconocido',
            additionalInfo: 'Código QR no válido o no registrado',
          );
        }
      }
    } catch (e) {
      _setResult(
        authorized: false,
        message: 'Error',
        visitorName: '',
        additionalInfo: 'No se pudo procesar el código QR',
      );
    }

    setState(() {
      _isProcessing = false;
      _scanComplete = true;
    });
  }

  void _setResult({
    required bool authorized,
    required String message,
    required String visitorName,
    required String additionalInfo,
  }) {
    setState(() {
      _isAuthorized = authorized;
      _resultMessage = message;
      _visitorName = visitorName;
      _additionalInfo = additionalInfo;
    });
  }

  void _resetScanner() {
    setState(() {
      _scanComplete = false;
      _isAuthorized = false;
      _resultMessage = '';
      _visitorName = '';
      _additionalInfo = '';
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear código QR'),
        actions: [
          if (!_scanComplete)
            IconButton(
              icon: Icon(Icons.flash_on),
              onPressed: () => _controller.toggleTorch(),
            ),
        ],
      ),
      body: _scanComplete ? _buildResultView() : _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
              _handleQRCode(barcodes.first.rawValue!);
            }
          },
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isProcessing
                      ? 'Procesando código...'
                      : 'Posicione el código QR dentro del marco',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (_isAuthorized ? Colors.green : Colors.red).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isAuthorized ? Icons.check_circle : Icons.cancel,
                size: 80,
                color: _isAuthorized ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 32),
            Text(
              _resultMessage,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _isAuthorized ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            if (_visitorName.isNotEmpty) ...[
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      _visitorName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_additionalInfo.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        _additionalInfo,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _resetScanner,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner),
                    SizedBox(width: 12),
                    Text(
                      'Escanear otro código',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
