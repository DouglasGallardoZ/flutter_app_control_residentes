import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/history/access_history_bloc.dart';
import '../../application/blocs/history/access_history_event.dart';
import '../../application/blocs/history/access_history_state.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../widgets/app_scaffold.dart';

class AccessHistoryPage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  final String? residenceId;
  const AccessHistoryPage({super.key, required this.personaId, required this.identificacion, this.residenceId});

  @override
  State<AccessHistoryPage> createState() => _AccessHistoryPageState();
}

class _AccessHistoryPageState extends State<AccessHistoryPage> {
  String statusFilter = 'Todos';
  String typeFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    context.read<AccessHistoryBloc>().add(LoadAccessHistory());
  }

  @override
  Widget build(BuildContext context) {
    // Try to recover route arguments for navigation between tabs
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final maybeResidenceId = routeArgs?['residenceId'] as String? ?? widget.residenceId;
    final maybeUserName = routeArgs?['userName'] as String?;
    final maybePersonaId = routeArgs?['personaId'] as int? ?? widget.personaId;
    final maybeIdentificacion = routeArgs?['identificacion'] as String? ?? widget.identificacion;
    // Fallback to AuthBloc if available
      final authState = context.read<AuthBloc>().state;
      String? authUserId;
      String? authResidence;
      String? authName;
      if (authState is AuthSuccess) {
        authUserId = (authState.user['id'] ?? authState.user['uid']) as String?;
        authResidence = authState.user['residence'] as String?;
        authName = authState.user['name'] as String?;
      }

    return AppScaffold(
      title: 'Historial de Accesos',
      currentIndex: 2,
      onTabSelected: (i) {
        switch (i) {
          case 0:
            final pid = maybePersonaId;
            final rid = maybeResidenceId;
            final idn = maybeIdentificacion;
            final uname = maybeUserName;
            if (pid != null && rid != null && idn.isNotEmpty && uname != null) {
              Navigator.pushReplacementNamed(context, '/residentDashboard', arguments: {'personaId': pid, 'identificacion': idn, 'residenceId': rid, 'userName': uname});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Inicio')));
            }
            break;
          case 1:
            final pid2 = maybePersonaId;
            final idn2 = maybeIdentificacion;
            final uname2 = maybeUserName;
            if (pid2 != null && idn2.isNotEmpty && uname2 != null) {
              Navigator.pushReplacementNamed(context, '/qrSelf', arguments: {'personaId': pid2, 'identificacion': idn2, 'userName': uname2});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Mi QR')));
            }
            break;
          case 2: break;
          case 3:
            final pid3 = maybePersonaId;
            final rid3 = maybeResidenceId;
            final idn3 = maybeIdentificacion;
            if (pid3 != null && rid3 != null && idn3.isNotEmpty) {
              Navigator.pushReplacementNamed(context, '/members', arguments: {'personaId': pid3, 'identificacion': idn3, 'residenceId': rid3});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Familia')));
            }
            break;
          case 4:
            final pid4 = maybePersonaId;
            final idn4 = maybeIdentificacion;
            if (pid4 != null && idn4.isNotEmpty) {
              Navigator.pushReplacementNamed(context, '/profile', arguments: {'personaId': pid4, 'identificacion': idn4});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Perfil')));
            }
            break;
        }
      },
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
