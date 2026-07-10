import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/member/member_bloc.dart';
import '../../application/blocs/member/member_event.dart';
import '../../application/blocs/member/member_state.dart';
import '../widgets/admin_scaffold.dart';

class AdminMembersPage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminMembersPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminMembersPage> createState() =>
      _AdminMembersPageState();
}

class _AdminMembersPageState
    extends State<AdminMembersPage> {
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
        .read<MemberBloc>()
        .add(LoadMembersByLocationEvent(
            manzana: m, villa: v));
  }

  void _recargar() {
    if (_lastManzana != null &&
        _lastVilla != null) {
      context
          .read<MemberBloc>()
          .add(LoadMembersByLocationEvent(
            manzana: _lastManzana!,
            villa: _lastVilla!,
          ));
    }
  }

  Future<void> _confirmarDesactivar(
    BuildContext context,
    Map<String, dynamic> member,
  ) async {
    final nombre =
        '${member['nombres'] ?? ''} ${member['apellidos'] ?? ''}'
            .trim();
    final motivoCtrl =
        TextEditingController();
    final memberId =
        member['miembro_id'] ??
            0;
    final confirmado =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
            'Desactivar Miembro'),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
                '¿Desactivar a $nombre? No podrá acceder a la vivienda.'),
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
                    backgroundColor:
                        Colors.orange),
            child: const Text(
                'Desactivar'),
          ),
        ],
      ),
    );
    if (confirmado == true &&
        context.mounted) {
      context
          .read<MemberBloc>()
          .add(DeactivateMemberEvent(
        memberId: memberId,
        reason: motivoCtrl
            .text
            .trim(),
      ));
    }
    motivoCtrl.dispose();
  }

  Future<void> _confirmarReactivar(
    BuildContext context,
    Map<String, dynamic> member,
  ) async {
    final nombre =
        '${member['nombres'] ?? ''} ${member['apellidos'] ?? ''}'
            .trim();
    final motivoCtrl =
        TextEditingController();
    final memberId =
        member['miembro_id'] ??
            0;
    final confirmado =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
            'Reactivar Miembro'),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
                '¿Reactivar a $nombre?'),
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
                    backgroundColor:
                        Colors.green),
            child: const Text(
                'Reactivar'),
          ),
        ],
      ),
    );
    if (confirmado == true &&
        context.mounted) {
      context
          .read<MemberBloc>()
          .add(ReactivateMemberEvent(
        memberId: memberId,
        reason: motivoCtrl
            .text
            .trim(),
      ));
    }
    motivoCtrl.dispose();
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    Map<String, dynamic> member,
  ) async {
    final nombre =
        '${member['nombres'] ?? ''} ${member['apellidos'] ?? ''}'
            .trim();
    final memberId =
        member['miembro_vivienda_pk'] ??
            member['miembroId'] ??
            0;
    final confirmado =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
            Icons.warning_amber,
            color: Colors.red,
            size: 48),
        title: const Text(
            'Eliminar Miembro'),
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
      context
          .read<MemberBloc>()
          .add(DeleteMemberEvent(
              memberId));
    }
  }

  void _verDetalle(
    Map<String, dynamic> member,
    String manzana,
    String villa,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _MemberDetailPage(
          member: member,
          manzana: manzana,
          villa: villa,
          onDesactivar: () =>
              _confirmarDesactivar(
                  context, member),
          onReactivar: () =>
              _confirmarReactivar(
                  context, member),
          onEliminar: () =>
              _confirmarEliminar(
                  context, member),
        ),
      ),
    );
  }

  String _parentescoLabel(
      String p) {
    const labels = {
      'padre': 'Padre',
      'madre': 'Madre',
      'esposo': 'Esposo',
      'esposa': 'Esposa',
      'hijo': 'Hijo',
      'hija': 'Hija',
    };
    return labels[p
            .toLowerCase()] ??
        p;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminScaffold(
      title: 'Gestión de Miembros',
      routeName: '/adminMembers',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.of(context)
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
                  .pushNamed('/adminCreateMember',
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
      body: BlocListener<MemberBloc,
          MemberState>(
        listener: (context, state) {
          if (state
              is MemberDeactivated) {
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
              is MemberReactivated) {
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
              is MemberDeleted) {
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
                  BlocBuilder<MemberBloc,
                      MemberState>(
                builder: (context,
                    state) {
                  if (state
                      is MemberLoading) {
                    return const Center(
                        child:
                            CircularProgressIndicator());
                  }

                  if (state
                      is MemberError) {
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
                      is MemberInitial) {
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
                            'Busca miembros por manzana y villa',
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
                      is MembersByLocationLoaded) {
                    if (state
                        .members
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
                              'No se encontraron miembros',
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
                            .members
                            .length,
                        itemBuilder: (context,
                            index) {
                          final m = state
                              .members[
                              index];
                          final nombre =
                              '${m['nombres'] ?? ''} ${m['apellidos'] ?? ''}'
                                  .trim();
                          final parentesco =
                              m['parentesco']
                                      ?.toString() ??
                                  '';
                          final parentescoLabel =
                              _parentescoLabel(
                                  parentesco);
                          final identificacion =
                              m['identificacion']
                                      ?.toString() ??
                                  '';
                          final activo = m['estado']
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
                                        .purple
                                        .withOpacity(0.15)
                                    : Colors
                                        .orange
                                        .withOpacity(0.15),
                                child: Icon(
                                  Icons
                                      .family_restroom,
                                  color: activo
                                      ? Colors
                                          .purple
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
                                  '$parentescoLabel · $identificacion · Mz ${state.manzana}, V ${state.villa}'),
                              trailing: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      parentescoLabel,
                                      style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (!activo) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Inactivo',
                                        style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () => _verDetalle(m, state.manzana, state.villa),
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

class _MemberDetailPage
    extends StatelessWidget {
  final Map<String, dynamic> member;
  final String manzana;
  final String villa;
  final VoidCallback onDesactivar;
  final VoidCallback onReactivar;
  final VoidCallback onEliminar;

  const _MemberDetailPage({
    required this.member,
    required this.manzana,
    required this.villa,
    required this.onDesactivar,
    required this.onReactivar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nombre =
        '${member['nombres'] ?? ''} ${member['apellidos'] ?? ''}'
            .trim();
    final activo = member['estado']
            ?.toString() ==
        'activo';
    final parentesco =
        member['parentesco']
                ?.toString() ??
            '';
    final parentescoLabel =
        _parentescoLabel(
            parentesco);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Detalle del Miembro'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              if (activo)
                const PopupMenuItem(
                  value: 'deactivate',
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
                  value: 'reactivate',
                  child: ListTile(
                    leading: Icon(
                        Icons.check_circle,
                        color:
                            Colors.green),
                    title: Text(
                        'Reactivar'),
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
                case 'deactivate':
                  onDesactivar();
                case 'reactivate':
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
                backgroundColor: Colors
                    .purple
                    .withOpacity(0.15),
                child: Text(
                  nombre.isNotEmpty
                      ? nombre[0]
                          .toUpperCase()
                      : 'M',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.purple,
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
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color: activo
                          ? Colors.green
                              .withOpacity(
                                  0.15)
                          : Colors.orange
                              .withOpacity(
                                  0.15),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
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
                            FontWeight
                                .bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 8),
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.purple
                          .withOpacity(
                              0.15),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
                    ),
                    child: Text(
                      parentescoLabel,
                      style: const TextStyle(
                        color:
                            Colors.purple,
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 32),
          _sectionTitle(context,
              'Información Personal'),
          const SizedBox(height: 12),
          _detailCard(context, [
            _DetailField(
              'Identificación',
              member[
                      'identificacion']
                  ?.toString(),
            ),
            _DetailField(
              'Nombres',
              member['nombres']
                  ?.toString(),
            ),
            _DetailField(
              'Apellidos',
              member['apellidos']
                  ?.toString(),
            ),
            _DetailField(
              'Parentesco',
              parentescoLabel,
            ),
            _DetailField(
              'Correo',
              member['correo']
                  ?.toString(),
            ),
            _DetailField(
              'Celular',
              member['celular']
                  ?.toString(),
            ),
            _DetailField(
                'Manzana', manzana),
            _DetailField(
                'Villa', villa),
          ]),
        ],
      ),
    );
  }

  String _parentescoLabel(
      String p) {
    const labels = {
      'padre': 'Padre',
      'madre': 'Madre',
      'esposo': 'Esposo',
      'esposa': 'Esposa',
      'hijo': 'Hijo',
      'hija': 'Hija',
    };
    return labels[p
            .toLowerCase()] ??
        p;
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
              fontWeight:
                  FontWeight.bold),
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
