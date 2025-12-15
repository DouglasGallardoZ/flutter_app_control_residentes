import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;
  const MetricCard({super.key, required this.label, required this.value, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: c),
            if (icon != null) const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: c)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
