import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_event.dart';
import '../../application/blocs/admin/admin_dashboard_state.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../widgets/admin_scaffold.dart';

class AdminAccessHistoryPage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminAccessHistoryPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminAccessHistoryPage> createState() => _AdminAccessHistoryPageState();
}

class _AdminAccessHistoryPageState extends State<AdminAccessHistoryPage> {
  String statusFilter = 'Todos';
  String typeFilter = 'Todos';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Cargar métricas (que incluyen historial)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardBloc>().add(const LoadAdminMetrics());
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String adminName = 'Administrador';
    if (authState is AuthSuccess) {
      final nombres = authState.user['nombres'] as String? ?? '';
      final apellidos = authState.user['apellidos'] as String? ?? '';
      adminName = '$nombres $apellidos'.trim();
    }

    return AdminScaffold(
      title: 'Historial de Accesos',
      routeName: '/adminAccessHistory',
      onTabSelected: (index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (index) {
            case 0:
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/adminDashboard',
                (route) => false,
                arguments: {
                  'personaId': widget.personaId,
                  'identificacion': widget.identificacion,
                },
              );
              break;
            case 1:
              // Ya estamos aquí
              break;
            case 2:
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/adminUsers',
                (route) => false,
                arguments: {
                  'personaId': widget.personaId,
                  'identificacion': widget.identificacion,
                },
              );
              break;
            case 3:
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/adminProfile',
                (route) => false,
                arguments: {
                  'personaId': widget.personaId,
                  'identificacion': widget.identificacion,
                },
              );
              break;
            case 4:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/adminNotificaciones', (route) => false,
                  arguments: {
                    'personaId': widget.personaId,
                    'identificacion': widget.identificacion,
                  });
              break;
          }
        });
      },
      body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          if (state is AdminDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminDashboardBloc>().add(const RefreshAdminMetrics());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminDashboardLoaded) {
            final metrics = state.metrics as dynamic; // metrics es AdminMetrics
            final recentActivityList = (metrics is Map<String, dynamic>)
                ? metrics['recent_activity'] as List<dynamic>? ?? []
                : (metrics.recentActivity as List<dynamic>? ?? []);

            // Convertir RecentActivity objects a Map para procesamiento uniforme
            final recentActivity = recentActivityList.map((item) {
              if (item is Map<String, dynamic>) {
                return item;
              } else {
                // Si es un objeto RecentActivity, convertir a Map
                return {
                  'person_name': item.personName ?? '—',
                  'person_role': item.personRole ?? '',
                  'access_type': item.accessType ?? 'own',
                  'related_person': item.relatedPerson ?? '',
                  'timestamp': item.timestamp?.toIso8601String() ?? '',
                  'entry_point': item.entryPoint ?? '—',
                  'is_successful': item.isSuccessful ?? true,
                };
              }
            }).toList() as List<dynamic>;

            // Aplicar filtros
            final filteredActivity = recentActivity.where((item) {
              final activity = item as Map<String, dynamic>;
              final personName = activity['person_name'] as String? ?? '';
              final isSuccessful = activity['is_successful'] as bool? ?? true;
              final accessType = activity['access_type'] as String? ?? 'own';

              // Filtrar por búsqueda
              if (searchQuery.isNotEmpty) {
                if (!personName.toLowerCase().contains(searchQuery.toLowerCase())) {
                  return false;
                }
              }

              // Filtrar por estado
              if (statusFilter != 'Todos') {
                final statusMatches = (statusFilter == 'Exitoso' && isSuccessful) ||
                    (statusFilter == 'Rechazado' && !isSuccessful);
                if (!statusMatches) return false;
              }

              // Filtrar por tipo
              if (typeFilter != 'Todos') {
                final typeMatches = (typeFilter == 'Propio' && accessType == 'own') ||
                    (typeFilter == 'Visitante' && accessType == 'visitor');
                if (!typeMatches) return false;
              }

              return true;
            }).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AdminDashboardBloc>().add(const RefreshAdminMetrics());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Filtros
                  _buildFilters(),
                  const SizedBox(height: 16),

                  // Búsqueda
                  TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar por nombre o identificación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Historial de accesos
                  Text(
                    'Últimos Accesos (${filteredActivity.length} de ${recentActivity.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  if (filteredActivity.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          recentActivity.isEmpty 
                            ? 'No hay accesos registrados'
                            : 'No hay accesos que coincidan con los filtros',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredActivity.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final activity = filteredActivity[index] as Map<String, dynamic>;
                        final personName = activity['person_name'] as String? ?? '—';
                        final accessType = activity['access_type'] as String? ?? 'own';
                        final timestamp = activity['timestamp'] as String? ?? '';
                        final isSuccessful = activity['is_successful'] as bool? ?? true;
                        final entryPoint = activity['entry_point'] as String? ?? '—';

                        return ListTile(
                          leading: Icon(
                            isSuccessful ? Icons.check_circle : Icons.cancel,
                            color: isSuccessful ? Colors.green : Colors.red,
                          ),
                          title: Text(personName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$entryPoint • ${_formatTime(timestamp)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                accessType == 'own' ? 'Acceso propio' : 'Visitante',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(isSuccessful ? 'Exitoso' : 'Rechazado'),
                            backgroundColor: isSuccessful ? Colors.green.shade100 : Colors.red.shade100,
                            labelStyle: TextStyle(
                              color: isSuccessful ? Colors.green.shade900 : Colors.red.shade900,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            value: statusFilter,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Todos', child: Text('Todos los estados')),
              DropdownMenuItem(value: 'Exitoso', child: Text('Exitoso')),
              DropdownMenuItem(value: 'Rechazado', child: Text('Rechazado')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => statusFilter = value);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<String>(
            value: typeFilter,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Todos', child: Text('Todos los tipos')),
              DropdownMenuItem(value: 'Propio', child: Text('Propio')),
              DropdownMenuItem(value: 'Visitante', child: Text('Visitante')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => typeFilter = value);
            },
          ),
        ),
      ],
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Hace un momento';
      if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}m';
      if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
      if (diff.inDays < 7) return 'Hace ${diff.inDays}d';

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return timestamp;
    }
  }
}
