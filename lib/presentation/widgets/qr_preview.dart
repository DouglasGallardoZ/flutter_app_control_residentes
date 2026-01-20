import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPreview extends StatelessWidget {
  final String value;
  const QrPreview({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QrImageView(
        data: value,
        version: QrVersions.auto,
        size: 220,
        gapless: true,
      ),
    );
  }
}
