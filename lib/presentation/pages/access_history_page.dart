import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/history/access_history_bloc.dart';
import '../../application/blocs/history/access_history_event.dart';
import '../../application/blocs/history/access_history_state.dart';
import '../widgets/app_scaffold.dart';

class AccessHistoryPage extends StatefulWidget {
  final String userId;
  const AccessHistoryPage({super.key, required this.userId});

  @override
  State<AccessHistoryPage> createState() => _AccessHistoryPageState();
}

class _AccessHistoryPageState extends State<AccessHistoryPage> {
  String statusFilter = 'Todos';
  String typeFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    context.read<AccessHistoryBloc>().add(LoadAccessHistory(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Historial de Accesos',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              FilterChip(
                label: const Text('Todos'),
                selected: statusFilter == 'Todos',
                onSelected: (_) => setState(() => statusFilter = 'Todos'),
              ),
              FilterChip(
                label: const Text('Exitosos'),
                selected: statusFilter == 'Exitosos',
                onSelected: (_) => setState(() => statusFilter = 'Exitosos'),
              ),
              FilterChip(
                label: const Text('Rechazados'),
                selected: statusFilter == 'Rechazados',
                onSelected: (_) => setState(() => statusFilter = 'Rechazados'),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('Propios'),
                selected: typeFilter == 'Propios',
                onSelected: (_) => setState(() => typeFilter = 'Propios'),
              ),
              FilterChip(
                label: const Text('Visitantes'),
                selected: typeFilter == 'Visitantes',
                onSelected: (_) => setState(() => typeFilter = 'Visitantes'),
              ),
            ]),
          ),
          Expanded(
            child: BlocBuilder<AccessHistoryBloc, AccessHistoryState>(
              builder: (ctx, state) {
                if (state is AccessHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AccessHistoryLoaded) {
                  final logs = state.logs.where((l) {
                    final statusOk = statusFilter == 'Todos' || (l.success && statusFilter == 'Exitosos') || (!l.success && statusFilter == 'Rechazados');
                    final typeOk = typeFilter == 'Todos' || (typeFilter == 'Propios' && l.referencedBy == null) || (typeFilter == 'Visitantes' && l.referencedBy != null);
                    return statusOk && typeOk;
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: logs.length,
                    itemBuilder: (ctx, i) {
                      final l = logs[i];
                      return Card(
                        child: ListTile(
                          title: Text(l.referencedBy == null ? 'Acceso propio' : 'Visitante: ${l.personName}'),
                          subtitle: Text('${l.personName} · ${l.timestamp}'),
                          trailing: Icon(l.success ? Icons.check_circle : Icons.cancel,
                              color: l.success ? const Color(0xFF10B981) : Theme.of(context).colorScheme.error),
                        ),
                      );
                    },
                  );
                } else if (state is AccessHistoryError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
