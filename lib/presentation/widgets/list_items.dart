import 'package:flutter/material.dart';

class HistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool success;
  final VoidCallback? onTap;

  const HistoryItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.success,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(success ? Icons.check_circle : Icons.cancel,
          color: success ? Colors.green : Colors.red),
      onTap: onTap,
    );
  }
}
