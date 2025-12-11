import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/qr_preview.dart';

class QrViewPage extends StatelessWidget {
  final String value;
  const QrViewPage({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR generado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            QrPreview(value: value),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Share.share('QR: $value'),
              child: const Text('Compartir'),
            ),
          ],
        ),
      ),
    );
  }
}
