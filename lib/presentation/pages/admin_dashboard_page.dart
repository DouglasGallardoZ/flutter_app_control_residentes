import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_event.dart';
import '../../application/blocs/admin/admin_dashboard_state.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../widgets/admin_scaffold.dart';

class AdminDashboardPage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  const AdminDashboardPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _selectedTimeFilter = 'today'; // 'today', 'week', 'month', 'custom'
  String? _customFechaInicio;
  String? _customFechaFin;

  @override
  void initState() {
    super.initState();
    // Cargar métricas después de que el widget esté completamente construido
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
      title: 'Panel de Administración',
      routeName: '/adminDashboard',
      onTabSelected: (index) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (index) {
            case 0:
              // Ya está en dashboard
              break;
            case 1:
              // Historial de accesos admin
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/adminAccessHistory',
                (route) => false,
                arguments: {
                  'personaId': widget.personaId,
                  'identificacion': widget.identificacion,
                },
              );
              break;
            case 2:
              // Gestión de usuarios
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
              // Configuración/Perfil admin
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/adminProfile',
                (route) => false,
                arguments: {
                  'personaId': widget.personaId,
                  'identificacion': widget.identificacion,
                },
              );
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
            final metrics = state.metrics;
            // Actualizar el filtro seleccionado en el estado local
            _selectedTimeFilter = state.currentTimeFilter;
            _customFechaInicio = state.customFechaInicio;
            _customFechaFin = state.customFechaFin;
            
            return _buildDashboard(context, adminName, metrics, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    String adminName,
    dynamic metrics,
    AdminDashboardLoaded state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminDashboardBloc>().add(const RefreshAdminMetrics());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          _buildHeader(adminName),
          const SizedBox(height: 24),

          // Tabs: Hoy, Semana, Mes
          _buildTimeTabs(),
          const SizedBox(height: 24),

          // Métricas principales
          _buildMetricsGrid(metrics),
          const SizedBox(height: 24),

          // Actividad reciente
          _buildRecentActivity(metrics),
          const SizedBox(height: 24),

          // Acciones rápidas
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(String adminName) {
    String dateRangeText = 'Hoy';
    if (_selectedTimeFilter == 'week') {
      dateRangeText = 'Últimos 7 días';
    } else if (_selectedTimeFilter == 'month') {
      dateRangeText = 'Últimos 30 días';
    } else if (_selectedTimeFilter == 'custom' && _customFechaInicio != null && _customFechaFin != null) {
      dateRangeText = 'Del $_customFechaInicio al $_customFechaFin';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $adminName',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Panel de Administración',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          'Período: $dateRangeText',
          style: TextStyle(fontSize: 12, color: Colors.blue.shade600, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTimeTabs() {
    const tabs = [
      ('today', 'Hoy'),
      ('week', 'Semana'),
      ('month', 'Mes'),
      ('custom', 'Rango'),
    ];
    
    return Wrap(
      spacing: 12,
      children: tabs.map((tabData) {
        final (filterType, label) = tabData;
        final isSelected = _selectedTimeFilter == filterType;
        
        return ChipButton(
          label: label,
          isSelected: isSelected,
          onTap: () async {
            if (filterType == 'custom') {
              // Mostrar date range picker
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(
                  start: DateTime.now().subtract(const Duration(days: 30)),
                  end: DateTime.now(),
                ),
              );
              
              if (picked != null) {
                setState(() {
                  _selectedTimeFilter = 'custom';
                  _customFechaInicio = picked.start.toIso8601String().split('T')[0];
                  _customFechaFin = picked.end.toIso8601String().split('T')[0];
                });
                
                if (mounted) {
                  context.read<AdminDashboardBloc>().add(
                    ChangeTimeFilter(
                      filterType: 'custom',
                      customFechaInicio: _customFechaInicio,
                      customFechaFin: _customFechaFin,
                    ),
                  );
                }
              }
            } else {
              setState(() {
                _selectedTimeFilter = filterType;
              });
              
              context.read<AdminDashboardBloc>().add(
                ChangeTimeFilter(filterType: filterType),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildMetricsGrid(dynamic metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        MetricCard(
          icon: Icons.check_circle,
          label: 'Accesos Totales',
          value: metrics.totalAccess.toString(),
          color: Colors.blue,
        ),
        MetricCard(
          icon: Icons.verified,
          label: 'Exitosos',
          value: metrics.successfulAccess.toString(),
          color: Colors.green,
        ),
        MetricCard(
          icon: Icons.cancel,
          label: 'Rechazados',
          value: metrics.deniedAccess.toString(),
          color: Colors.red,
        ),
        MetricCard(
          icon: Icons.people,
          label: 'Visitantes',
          value: metrics.visitors.toString(),
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(dynamic metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad Reciente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (metrics.recentActivity.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No hay actividad reciente',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.recentActivity.length,
            itemBuilder: (context, index) {
              final activity = metrics.recentActivity[index];
              return ActivityTile(activity: activity);
            },
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          icon: Icons.people_outline,
          label: 'Gestionar Usuarios',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gestión de usuarios - Próximamente')),
            );
          },
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          icon: Icons.history,
          label: 'Ver Bitácora Completa',
          onTap: () {
            Navigator.of(context).pushNamed(
              '/accessHistory',
              arguments: {
                'personaId': widget.personaId,
                'identificacion': widget.identificacion,
              },
            );
          },
        ),
        const SizedBox(height: 12),
        QuickActionButton(
          icon: Icons.settings_outlined,
          label: 'Configuración de Usuarios',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Configuración - Próximamente')),
            );
          },
        ),
      ],
    );
  }
}

class ChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ChipButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final dynamic activity;

  const ActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: activity.isSuccessful ? Colors.green[100] : Colors.red[100],
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              activity.isSuccessful ? Icons.check_circle : Icons.cancel,
              color: activity.isSuccessful ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.displayLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.personName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  activity.entryPoint,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.shortTime,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
