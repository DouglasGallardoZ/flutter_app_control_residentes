import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/history/access_history_bloc.dart';
import '../blocs/history/access_history_state.dart';
import '../blocs/history/access_history_event.dart';

class AccessHistoryPage extends StatelessWidget {
  final String userId;
  const AccessHistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    context.read<AccessHistoryBloc>().add(LoadAccessHistory(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de accesos')),
      body: BlocBuilder<AccessHistoryBloc, AccessHistoryState>(
        builder: (ctx, state) {
          if (state is AccessHistoryLoading) return const Center(child: CircularProgressIndicator());
          if (state is AccessHistoryLoaded) {
            final logs = state.logs;
            if (logs.isEmpty) return const Center(child: Text('Sin registros'));
            return ListView.separated(
              itemCount: logs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final item = logs[i];
                return ListTile(
                  title: Text(item.personName),
                  subtitle: Text('${item.roleLabel} • ${item.timestamp}'),
                  trailing: Icon(item.success ? Icons.check_circle : Icons.cancel,
                      color: item.success ? Colors.green : Colors.red),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Detalle de acceso'),
                      content: Text(item.detailMessage),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
