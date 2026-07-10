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
  State<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}

class _AdminDashboardPageState
    extends State<AdminDashboardPage> {
  String _selectedFilter = 'today';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<AdminDashboardBloc>()
          .add(const LoadAdminMetrics());
    });
  }

  void _changeFilter(String filter) {
    setState(() => _selectedFilter = filter);
    context.read<AdminDashboardBloc>().add(
          ChangeTimeFilter(filterType: filter),
        );
  }

  String get _filterLabel {
    return switch (_selectedFilter) {
      'today' => 'Hoy',
      'week' => 'Últimos 7 días',
      'month' => 'Últimos 30 días',
      _ => 'Hoy',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState =
        context.read<AuthBloc>().state;
    String adminName = 'Administrador';
    if (authState is AuthSuccess) {
      final nombres = authState
              .user['nombres'] as String? ??
          '';
      final apellidos = authState
              .user['apellidos'] as String? ??
          '';
      adminName =
          '$nombres $apellidos'.trim();
    }

    return AdminScaffold(
      title: 'Dashboard',
      routeName: '/adminDashboard',
      onTabSelected: (index) {
        if (index == 0) return;
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          final routes = [
            null,
            '/adminAccessHistory',
            '/adminUsers',
            '/adminProfile',
            '/adminNotificaciones',
            '/adminViviendas',
          ];
          if (routes[index] != null) {
            Navigator.of(context)
                .pushReplacementNamed(
              routes[index]!,
              arguments: {
                'personaId': widget.personaId,
                'identificacion':
                    widget.identificacion,
              },
            );
          }
        });
      },
      body: BlocBuilder<AdminDashboardBloc,
          AdminDashboardState>(
        builder: (context, state) {
          if (state is AdminDashboardLoading) {
            return const Center(
                child:
                    CircularProgressIndicator());
          }
          if (state is AdminDashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48,
                      color: theme
                          .colorScheme
                          .error),
                  const SizedBox(height: 16),
                  Text(state.message,
                      textAlign:
                          TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<AdminDashboardBloc>()
                        .add(const RefreshAdminMetrics()),
                    icon: const Icon(
                        Icons.refresh),
                    label: const Text(
                        'Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state
              is AdminDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<AdminDashboardBloc>()
                    .add(const RefreshAdminMetrics());
              },
              child: _buildDashboard(
                  context,
                  adminName,
                  state),
            );
          }
          return const SizedBox
              .shrink();
        },
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    String adminName,
    AdminDashboardLoaded state,
  ) {
    final metrics = state.metrics;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(
            context, adminName),
        const SizedBox(height: 24),
        _buildFilterChips(context),
        const SizedBox(height: 24),
        _buildMetricsGrid(
            context, metrics),
        const SizedBox(height: 24),
        _buildRecentActivity(
            context, metrics),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context,
      String adminName) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: theme
              .colorScheme.primary
              .withOpacity(0.15),
          child: Text(
            adminName.isNotEmpty
                ? adminName[0]
                    .toUpperCase()
                : 'A',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme
                  .colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $adminName',
                style: theme
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                        fontWeight:
                            FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _filterLabel,
                style: theme
                    .textTheme.bodyMedium
                    ?.copyWith(
                        color: theme
                            .colorScheme
                            .primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
      BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Hoy',
            selected:
                _selectedFilter == 'today',
            onTap: () =>
                _changeFilter('today'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '7 días',
            selected:
                _selectedFilter == 'week',
            onTap: () =>
                _changeFilter('week'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '30 días',
            selected:
                _selectedFilter == 'month',
            onTap: () =>
                _changeFilter('month'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
      BuildContext context,
      dynamic metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _MetricCard(
          icon: Icons.login,
          label: 'Accesos Totales',
          value: '${metrics.totalAccess}',
          color: Colors.blue,
        ),
        _MetricCard(
          icon: Icons.check_circle,
          label: 'Exitosos',
          value: '${metrics.successfulAccess}',
          color: Colors.green,
        ),
        _MetricCard(
          icon: Icons.cancel,
          label: 'Rechazados',
          value: '${metrics.deniedAccess}',
          color: Colors.red,
        ),
        _MetricCard(
          icon: Icons.people,
          label: 'Visitantes',
          value: '${metrics.visitors}',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(
      BuildContext context,
      dynamic metrics) {
    final theme = Theme.of(context);
    final activities =
        metrics.recentActivity as List;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: theme.textTheme.titleMedium
              ?.copyWith(
                  fontWeight:
                      FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(
                    vertical: 24),
            child: Center(
              child: Text(
                'No hay actividad reciente',
                style: TextStyle(
                    color:
                        Colors.grey.shade600),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity =
                  activities[index];
              final personName = activity
                      .personName ??
                  '';
              final isSuccessful = activity
                      .isSuccessful ??
                  true;
              final entryPoint = activity
                      .entryPoint ??
                  '';
              final shortTime = activity
                      .shortTime ??
                  '';
              final displayLabel = activity
                      .displayLabel ??
                  '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isSuccessful
                          ? Colors.green
                              .withOpacity(
                                  0.15)
                          : Colors.red
                              .withOpacity(
                                  0.15),
                  child: Icon(
                    isSuccessful
                        ? Icons
                            .check_circle
                        : Icons.cancel,
                    color: isSuccessful
                        ? Colors.green
                        : Colors.red,
                    size: 20,
                  ),
                ),
                title:
                    Text(personName),
                subtitle: Text(
                  '$entryPoint • $displayLabel',
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color:
                        theme.hintColor,
                  ),
                ),
                trailing: Text(
                  shortTime,
                  style: theme
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                    color:
                        theme.hintColor,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor:
          const Color(0xFF04345C),
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : theme.textTheme.bodyMedium
                ?.color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding:
                  const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: color, size: 24),
            ),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                          fontWeight:
                              FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme
                      .textTheme.bodySmall
                      ?.copyWith(
                          color:
                              Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
