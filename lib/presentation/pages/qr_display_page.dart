import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/app_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../application/blocs/qr/qr_bloc.dart';
import '../../application/blocs/qr/qr_state.dart';
import '../widgets/navigation_helpers.dart';

class QrDisplayPage extends StatefulWidget {
  final String userName;
  final int personaId;
  final String identificacion;
  final DateTime validFrom;
  final DateTime validUntil;
  final int durationHours;
  final String qrValue;
  // Datos opcionales de la visita (si es QR de visita)
  final String? visitName;
  final String? visitIdentificacion;

  const QrDisplayPage({
    super.key,
    required this.userName,
    required this.personaId,
    required this.identificacion,
    required this.validFrom,
    required this.validUntil,
    required this.durationHours,
    required this.qrValue,
    this.visitName,
    this.visitIdentificacion,
  });

  @override
  State<QrDisplayPage> createState() => _QrDisplayPageState();
}

class _QrDisplayPageState extends State<QrDisplayPage> {
  final GlobalKey qrBoundaryKey = GlobalKey();

  String _fmtShortES(DateTime dt) {
    const months = ['ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic'];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]}, $hh:$mm';
  }

  Future<void> _shareQr() async {
    try {
      final boundary = qrBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await Directory.systemTemp.createTemp('qrshare');
      final file = File('${tempDir.path}/qr.png');
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Código QR de acceso');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Acción completada!')));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo compartir')));
    }
  }

  Future<void> _downloadQr() async {
    try {
      final boundary = qrBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final tempDir = await Directory.systemTemp.createTemp('qrdownload');
      final file = File('${tempDir.path}/qr.png');
      await file.writeAsBytes(pngBytes);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Acción completada!')));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo descargar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final separatorColor = theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300;

    // Obtener datos de navegación desde QrBloc (almacenados por qr_visit_page)
    final qrBloc = context.read<QrBloc>();
    final qrState = qrBloc.state;
    
    final authState = context.read<AuthBloc>().state;
    String? authUserId;
    String? authResidence;
    String? authName;
    if (authState is AuthSuccess) {
      authUserId = (authState.user['id'] ?? authState.user['uid'])?.toString();
      authResidence = authState.user['residence'] as String?;
      authName = authState.user['name'] as String?;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Navigator.pushReplacementNamed(context, '/residentDashboard');
        }
      },
      child: AppScaffold(
        title: 'Código QR',
        routeName: '/qrSelf',
        onTabSelected: (i) {
          if (i == 1) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              debugPrint('[QrDisplayPage] onTabSelected called with i=$i');
              switch (i) {
                case 0:
                  debugPrint('[QrDisplayPage Tab0] Navigating to ResidentDashboard');
                  Navigator.of(context).pushNamedAndRemoveUntil('/residentDashboard', (route) => false);
                  break;
                case 2:
                  debugPrint('[QrDisplayPage Tab2] Navigating to AccessHistory');
                  Navigator.of(context).pushNamedAndRemoveUntil('/accessHistory', (route) => false);
                  break;
                case 3:
                  debugPrint('[QrDisplayPage Tab3] Navigating to Members');
                  Navigator.of(context).pushNamedAndRemoveUntil('/members', (route) => false);
                  break;
                case 4:
                  debugPrint('[QrDisplayPage Tab4] Navigating to Profile');
                  Navigator.of(context).pushNamedAndRemoveUntil('/profile', (route) => false);
                  break;
              }
            } catch (e) {
              debugPrint('[QrDisplayPage] ERROR en onTabSelected: $e');
            }
          });
        },
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          Center(
            child: Container(
              width: 220,
              height: 220,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: separatorColor),
              ),
              child: RepaintBoundary(
                key: qrBoundaryKey,
                child: QrImageView(
                  data: widget.qrValue,
                  version: QrVersions.auto,
                  size: 200,
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Tu Código de Acceso', style: theme.textTheme.titleMedium),
          Text('Muestra este código en el punto de acceso', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: separatorColor),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              _DetailRow(
                label: 'Válido para:',
                value: widget.visitName ?? widget.userName,
              ),
              _DetailRow(
                label: 'Identificación:',
                value: widget.visitIdentificacion ?? widget.identificacion,
              ),
              _DetailRow(label: 'Válido desde:', value: _fmtShortES(widget.validFrom)),
              _DetailRow(label: 'Válido hasta:', value: _fmtShortES(widget.validUntil)),
              _DetailRow(label: 'Duración:', value: '${widget.durationHours} horas'),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _shareQr, icon: const Icon(Icons.share), label: const Text('Compartir'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: _downloadQr, icon: const Icon(Icons.download), label: const Text('Descargar'))),
          ]),
        ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 140, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
      ]),
    );
  }
}
