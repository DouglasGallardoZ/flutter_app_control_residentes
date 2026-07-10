import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/resident/resident_bloc.dart';
import '../../application/blocs/resident/resident_event.dart';
import '../../application/blocs/resident/resident_state.dart';
import '../widgets/admin_scaffold.dart';

class AdminResidentsPage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminResidentsPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminResidentsPage> createState() =>
      _AdminResidentsPageState();
}

class _AdminResidentsPageState
    extends State<AdminResidentsPage> {
  final _manzanaCtrl =
      TextEditingController();
  final _villaCtrl =
      TextEditingController();
  String? _lastManzana;
  String? _lastVilla;

  @override
  void dispose() {
    _manzanaCtrl.dispose();
    _villaCtrl.dispose();
    super.dispose();
  }

  void _buscar() {
    final m =
        _manzanaCtrl.text.trim();
    final v =
        _villaCtrl.text.trim();
    if (m.isEmpty || v.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
            content: Text(
                'Ingresa manzana y villa')),
      );
      return;
    }
    _lastManzana = m;
    _lastVilla = v;
    context
        .read<ResidentBloc>()
        .add(LoadResidentsByLocationEvent(
            manzana: m, villa: v));
  }

  void _recargar() {
    if (_lastManzana != null &&
        _lastVilla != null) {
      context
          .read<ResidentBloc>()
          .add(LoadResidentsByLocationEvent(
            manzana: _lastManzana!,
            villa: _lastVilla!,
          ));
    }
  }

  Future<void> _confirmarBloqueo(
    BuildContext context,
    Map<String, dynamic> resident,
    bool bloquear,
  ) async {
    final nombre =
        '${resident['nombres'] ?? ''} ${resident['apellidos'] ?? ''}'
            .trim();
    final motivoCtrl =
        TextEditingController();
    final confirmado =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(bloquear
            ? 'Desactivar Residente'
            : 'Reactivar Residente'),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(bloquear
                ? '¿Desactivar a $nombre? No podrá generar QR ni acceder.'
                : '¿Reactivar a $nombre?'),
            const SizedBox(
                height: 16),
            TextField(
              controller:
                  motivoCtrl,
              decoration:
                  const InputDecoration(
                labelText: 'Motivo',
                border:
                    OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    ctx, false),
            child: const Text(
                'Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(
                    ctx, true),
            style: FilledButton
                .styleFrom(
              backgroundColor: bloquear
                  ? Colors.orange
                  : Colors.green,
            ),
            child: Text(bloquear
                ? 'Desactivar'
                : 'Reactivar'),
          ),
        ],
      ),
    );
    if (confirmado == true &&
        context.mounted) {
      final personaId = resident[
              'persona_id'] ??
          resident[
              'residente_id'] ??
          resident['personaId'] ??
          0;
      if (bloquear) {
        context
            .read<ResidentBloc>()
            .add(DeactivateResidentEvent(
              personaId: personaId,
              reason: motivoCtrl
                  .text
                  .trim(),
            ));
      } else {
        context
            .read<ResidentBloc>()
            .add(ReactivateResidentEvent(
              personaId: personaId,
              reason: motivoCtrl
                  .text
                  .trim(),
            ));
      }
    }
    motivoCtrl.dispose();
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    Map<String, dynamic> resident,
  ) async {
    final nombre =
        '${resident['nombres'] ?? ''} ${resident['apellidos'] ?? ''}'
            .trim();
    final confirmado =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
            Icons.warning_amber,
            color: Colors.red,
            size: 48),
        title: const Text(
            'Eliminar Residente'),
        content: Text(
            '¿Eliminar permanentemente a $nombre? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    ctx, false),
            child: const Text(
                'Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(
                    ctx, true),
            style: FilledButton
                .styleFrom(
                    backgroundColor:
                        Colors.red),
            child: const Text(
                'Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado == true &&
        context.mounted) {
      final personaId = resident[
              'persona_id'] ??
          resident[
              'residente_id'] ??
          resident['personaId'] ??
          0;
      context
          .read<ResidentBloc>()
          .add(DeleteResidentEvent(
              personaId));
    }
  }

  void _verDetalle(
      Map<String, dynamic> resident,
      String manzana,
      String villa) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _ResidentDetailPage(
          resident: resident,
          manzana: manzana,
          villa: villa,
          onBloquear: () =>
              _confirmarBloqueo(
                  context,
                  resident,
                  true),
          onReactivar: () =>
              _confirmarBloqueo(
                  context,
                  resident,
                  false),
          onEliminar: () =>
              _confirmarEliminar(
                  context, resident),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminScaffold(
      title: 'Gestión de Residentes',
      routeName: '/adminResidents',
      showBackButton: true,
      onBackPressed: () => Navigator
          .of(context)
          .pushReplacementNamed(
        '/adminUsers',
        arguments: {
          'personaId':
              widget.personaId,
          'identificacion':
              widget.identificacion,
        },
      ),
      onTabSelected: (i) {
        if (i == 2) return;
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          final routes = [
            '/adminDashboard',
            '/adminAccessHistory',
            null,
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
      actions: [
        TextButton.icon(
          onPressed: () =>
              Navigator.of(context)
                  .pushNamed('/adminCreateResident',
                      arguments: {
                        'personaId': widget.personaId,
                        'identificacion': widget.identificacion,
                      }),
          icon: const Icon(
              Icons.person_add),
          label:
              const Text('Registrar'),
        ),
      ],
      body: BlocListener<ResidentBloc,
          ResidentState>(
        listener: (context, state) {
          if (state
              is ResidentDeactivated) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(SnackBar(
              content:
                  Text(state.message),
              backgroundColor:
                  Colors.orange,
            ));
            _recargar();
          } else if (state
              is ResidentReactivated) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(SnackBar(
              content:
                  Text(state.message),
              backgroundColor:
                  Colors.green,
            ));
            _recargar();
          } else if (state
              is ResidentDeleted) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(SnackBar(
              content:
                  Text(state.message),
              backgroundColor:
                  Colors.red,
            ));
            _recargar();
          }
        },
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.all(
                      16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          _manzanaCtrl,
                      decoration: InputDecoration(
                        hintText:
                            'Manzana',
                        prefixIcon: const Icon(
                            Icons
                                .grid_view),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12)),
                        contentPadding: const EdgeInsets
                            .symmetric(
                            horizontal:
                                16,
                            vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 12),
                  Expanded(
                    child: TextField(
                      controller:
                          _villaCtrl,
                      decoration: InputDecoration(
                        hintText: 'Villa',
                        prefixIcon: const Icon(
                            Icons.home),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12)),
                        contentPadding: const EdgeInsets
                            .symmetric(
                            horizontal:
                                16,
                            vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 12),
                  FilledButton(
                    onPressed: _buscar,
                    style: FilledButton
                        .styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF04345C),
                      padding: const EdgeInsets
                          .symmetric(
                          horizontal:
                              20,
                          vertical: 14),
                    ),
                    child: const Icon(
                        Icons.search),
                  ),
                ],
              ),
            ),
            const Divider(
                height: 1),
            Expanded(
              child:
                  BlocBuilder<ResidentBloc,
                      ResidentState>(
                builder: (context,
                    state) {
                  if (state
                      is ResidentLoading) {
                    return const Center(
                        child:
                            CircularProgressIndicator());
                  }

                  if (state
                      is ResidentError) {
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
                      is ResidentInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Colors
                                .grey
                                .shade400,
                          ),
                          const SizedBox(
                              height:
                                  16),
                          Text(
                            'Busca residentes por manzana y villa',
                            style: theme
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: Colors
                                        .grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state
                      is ResidentsByLocationLoaded) {
                    if (state
                        .residents
                        .isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .person_off,
                              size: 64,
                              color: Colors
                                  .grey
                                  .shade400,
                            ),
                            const SizedBox(
                                height:
                                    16),
                            const Text(
                              'No se encontraron residentes',
                              style: TextStyle(
                                  color: Colors
                                      .grey),
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
                        itemCount: state
                            .residents
                            .length,
                        itemBuilder: (context,
                            index) {
                          final r = state
                                  .residents[
                              index];
                          final nombre =
                              '${r['nombres'] ?? ''} ${r['apellidos'] ?? ''}'
                                  .trim();
                          final identificacion =
                              r['identificacion']
                                      ?.toString() ??
                                  '';
                          final manzana = state.manzana;
                          final villa = state.villa;
                          final activo = r['estado']
                                      ?.toString() ==
                                  'activo';

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
                            child:
                                ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal:
                                      16,
                                  vertical:
                                      8),
                              leading: CircleAvatar(
                                backgroundColor: activo
                                    ? Colors
                                        .green
                                        .withOpacity(0.15)
                                    : Colors
                                        .orange
                                        .withOpacity(0.15),
                                child:
                                    Icon(
                                  Icons
                                      .person,
                                  color: activo
                                      ? Colors
                                          .green
                                      : Colors
                                          .orange,
                                ),
                              ),
                              title: Text(
                                nombre,
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600),
                              ),
                              subtitle: Text(
                                  '$identificacion · Mz $manzana, V $villa'),
                              trailing: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  if (!activo)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Inactivo',
                                        style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () => _verDetalle(r, state.manzana, state.villa),
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
      ),
    );
  }
}

class _ResidentDetailPage
    extends StatelessWidget {
  final Map<String, dynamic> resident;
  final String manzana;
  final String villa;
  final VoidCallback onBloquear;
  final VoidCallback onReactivar;
  final VoidCallback onEliminar;

  const _ResidentDetailPage({
    required this.resident,
    required this.manzana,
    required this.villa,
    required this.onBloquear,
    required this.onReactivar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nombre =
        '${resident['nombres'] ?? ''} ${resident['apellidos'] ?? ''}'
            .trim();
    final activo = resident['estado']
            ?.toString() ==
        'activo';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Detalle del Residente'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              if (activo)
                const PopupMenuItem(
                  value: 'block',
                  child: ListTile(
                    leading: Icon(
                        Icons.block,
                        color:
                            Colors.orange),
                    title: Text(
                        'Desactivar'),
                    contentPadding:
                        EdgeInsets.zero,
                  ),
                )
              else
                const PopupMenuItem(
                  value: 'unblock',
                  child: ListTile(
                    leading: Icon(
                        Icons.check_circle,
                        color:
                            Colors.green),
                    title:
                        Text('Reactivar'),
                    contentPadding:
                        EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                      Icons.delete,
                      color: Colors.red),
                  title:
                      Text('Eliminar'),
                  contentPadding:
                      EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (action) {
              switch (action) {
                case 'block':
                  onBloquear();
                case 'unblock':
                  onReactivar();
                case 'delete':
                  onEliminar();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: theme
                    .colorScheme.primary
                    .withOpacity(0.15),
                child: Text(
                  nombre.isNotEmpty
                      ? nombre[0]
                          .toUpperCase()
                      : 'R',
                  style: TextStyle(
                    fontSize: 32,
                    color: theme
                        .colorScheme
                        .primary,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                  height: 12),
              Text(nombre,
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                          fontWeight:
                              FontWeight
                                  .bold)),
              const SizedBox(
                  height: 4),
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: activo
                      ? Colors.green
                          .withOpacity(
                              0.15)
                      : Colors.orange
                          .withOpacity(
                              0.15),
                  borderRadius:
                      BorderRadius
                          .circular(12),
                ),
                child: Text(
                  activo
                      ? 'Activo'
                      : 'Inactivo',
                  style: TextStyle(
                    color: activo
                        ? Colors.green
                        : Colors.orange,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 32),
          _detailCard(context, [
            _DetailField(
              'Identificación',
              resident[
                      'identificacion']
                  ?.toString(),
            ),
            _DetailField(
              'Nombres',
              resident['nombres']
                  ?.toString(),
            ),
            _DetailField(
              'Apellidos',
              resident['apellidos']
                  ?.toString(),
            ),
            _DetailField(
              'Correo',
              resident['correo']
                  ?.toString(),
            ),
            _DetailField(
              'Celular',
              resident['celular']
                  ?.toString(),
            ),
            _DetailField(
              'Manzana',
              manzana,
            ),
            _DetailField(
              'Villa',
              villa,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _detailCard(
    BuildContext context,
    List<_DetailField> fields,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: fields
              .map((f) => Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                            vertical: 8),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            f.label,
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                              fontWeight:
                                  FontWeight
                                      .w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            f.value ??
                                '—',
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w500),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _DetailField {
  final String label;
  final String? value;
  const _DetailField(
      this.label, this.value);
}
