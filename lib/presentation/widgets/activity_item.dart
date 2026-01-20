import 'package:flutter/material.dart';

class ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool success;
  const ActivityItem({super.key, required this.title, required this.subtitle, required this.time, required this.success});

  @override
  Widget build(BuildContext context) {
    final color = success ? const Color(0xFF10B981) : Theme.of(context).colorScheme.error;
    final icon = success ? Icons.check_circle : Icons.cancel;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(time, style: const TextStyle(color: Color(0xFF6B7280))),
      ]),
    );
  }
}
