import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_event.dart';
import '../../application/blocs/admin/admin_dashboard_state.dart';
import '../widgets/admin_scaffold.dart';

class AdminAccessHistoryPage
    extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminAccessHistoryPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminAccessHistoryPage>
  createState() =>
      _AdminAccessHistoryPageState();
}

class _AdminAccessHistoryPageState
    extends State<AdminAccessHistoryPage> {
  String _statusFilter = 'all';
  String _typeFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<AdminDashboardBloc>()
          .add(const LoadAccessHistory());
    });
  }

  void _recargar() {
    context
        .read<AdminDashboardBloc>()
        .add(LoadAccessHistory(
      tipo: _typeFilter == 'all'
          ? null
          : _typeFilter,
      resultado: _statusFilter ==
              'all'
          ? null
          : _statusFilter,
    ));
  }

  Color _statusColor(
      String? status) {
    return switch (status) {
      'exitoso' => Colors.green,
      'rechazado' => Colors.red,
      _ => Colors.grey,
    };
  }

  IconData _statusIcon(
      String? status) {
    return switch (status) {
      'exitoso' =>
        Icons.check_circle,
      'rechazado' =>
        Icons.cancel,
      _ => Icons.help_outline,
    };
  }

  IconData _typeIcon(
      String? type) {
    return switch (type) {
      'propio' => Icons.person,
      'visitante' =>
        Icons.group,
      _ => Icons.login,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminScaffold(
      title: 'Historial de Accesos',
      routeName:
          '/adminAccessHistory',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.of(context)
              .pushReplacementNamed(
        '/adminDashboard',
        arguments: {
          'personaId':
              widget.personaId,
          'identificacion':
              widget.identificacion,
        },
      ),
      onTabSelected: (i) {
        if (i == 1) return;
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          final routes = [
            '/adminDashboard',
            null,
            '/adminUsers',
            '/adminProfile',
            '/adminNotificaciones',
          ];
          if (routes[i] != null) {
            Navigator.of(context)
                .pushReplacementNamed(
              routes[i]!,
              arguments: {
                'personaId':
                    widget.personaId,
                'identificacion':
                    widget.identificacion,
              },
            );
          }
        });
      },
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
                    16),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Todos',
                        selected:
                            _statusFilter ==
                                'all',
                        onTap: () =>
                            setState(() {
                          _statusFilter =
                              'all';
                          _recargar();
                        }),
                      ),
                      const SizedBox(
                          width: 8),
                      _FilterChip(
                        label:
                            'Exitosos',
                        selected:
                            _statusFilter ==
                                'exitoso',
                        color:
                            Colors.green,
                        onTap: () =>
                            setState(() {
                          _statusFilter =
                              'exitoso';
                          _recargar();
                        }),
                      ),
                      const SizedBox(
                          width: 8),
                      _FilterChip(
                        label:
                            'Rechazados',
                        selected:
                            _statusFilter ==
                                'rechazado',
                        color:
                            Colors.red,
                        onTap: () =>
                            setState(() {
                          _statusFilter =
                              'rechazado';
                          _recargar();
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                    height: 8),
                SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label:
                            'Todos los tipos',
                        selected:
                            _typeFilter ==
                                'all',
                        onTap: () =>
                            setState(() {
                          _typeFilter =
                              'all';
                          _recargar();
                        }),
                      ),
                      const SizedBox(
                          width: 8),
                      _FilterChip(
                        label: 'Propio',
                        selected:
                            _typeFilter ==
                                'propio',
                        color:
                            Colors.blue,
                        onTap: () =>
                            setState(() {
                          _typeFilter =
                              'propio';
                          _recargar();
                        }),
                      ),
                      const SizedBox(
                          width: 8),
                      _FilterChip(
                        label:
                            'Visitante',
                        selected:
                            _typeFilter ==
                                'visitante',
                        color: Colors
                            .purple,
                        onTap: () =>
                            setState(() {
                          _typeFilter =
                              'visitante';
                          _recargar();
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
              height: 1),
          Expanded(
            child: BlocBuilder<
                AdminDashboardBloc,
                AdminDashboardState>(
              builder: (context,
                  state) {
                if (state
                    is AccessHistoryLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator());
                }

                if (state
                    is AccessHistoryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons
                              .error_outline,
                          size: 48,
                          color: theme
                              .colorScheme
                              .error,
                        ),
                        const SizedBox(
                            height:
                                16),
                        Text(
                            state
                                .message,
                            textAlign:
                                TextAlign
                                    .center),
                        const SizedBox(
                            height:
                                16),
                        ElevatedButton
                            .icon(
                          onPressed:
                              _recargar,
                          icon: const Icon(
                              Icons
                                  .refresh),
                          label: const Text(
                              'Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state
                    is AccessHistoryLoaded) {
                  final accesos = state
                              .accessHistory[
                          'data']
                          as List<
                                  dynamic>? ??
                      [];

                  if (accesos
                      .isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons
                                .history,
                            size: 64,
                            color: Colors
                                .grey
                                .shade400,
                          ),
                          const SizedBox(
                              height:
                                  16),
                          const Text(
                            'No hay accesos registrados',
                            style: TextStyle(
                                color: Colors
                                    .grey),
                          ),
                          const SizedBox(
                              height:
                                  4),
                          Text(
                            _statusFilter != 'all' || _typeFilter != 'all'
                                ? 'Prueba cambiando los filtros'
                                : '',
                            style: TextStyle(
                                color: Colors
                                    .grey
                                    .shade500,
                                fontSize:
                                    13),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async =>
                        _recargar(),
                    child: ListView
                        .builder(
                      padding:
                          const EdgeInsets.all(16),
                      itemCount:
                          accesos.length,
                      itemBuilder: (context,
                          index) {
                        final acceso = accesos[
                                index]
                            as Map<String,
                                dynamic>;
                        final nombre = acceso['nombre']
                                    ?.toString() ??
                                acceso['nombres']
                                    ?.toString() ??
                                '—';
                        final tipo = acceso['tipo']
                                    ?.toString() ??
                                acceso['tipo_ingreso']
                                    ?.toString() ??
                                '';
                        final resultado =
                            acceso['resultado']
                                    ?.toString() ??
                                '';
                        final fecha = acceso['fecha']
                                    ?.toString() ??
                                acceso['fecha_acceso']
                                    ?.toString() ??
                                '';
                        final hora = acceso['hora']
                                    ?.toString() ??
                                '';

                        return Card(
                          margin: const EdgeInsets
                              .only(
                              bottom:
                                  12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(16)),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _statusColor(resultado).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _statusIcon(resultado),
                                    color: _statusColor(resultado),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(nombre,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(_typeIcon(tipo), size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            tipo == 'propio' ? 'Acceso propio' : 'Visitante',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _statusColor(resultado).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        resultado == 'exitoso'
                                            ? 'Exitoso'
                                            : resultado == 'rechazado'
                                                ? 'Rechazado'
                                                : resultado,
                                        style: TextStyle(
                                          color: _statusColor(resultado),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(fecha,
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    if (hora.isNotEmpty)
                                      Text(hora,
                                          style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox
                    .shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip
    extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context) {
    final chipColor = color ??
        const Color(0xFF04345C);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor,
      labelStyle: TextStyle(
        color: selected
            ? Colors.white
            : null,
        fontWeight:
            FontWeight.w600,
        fontSize: 13,
      ),
      visualDensity:
          VisualDensity.compact,
    );
  }
}
