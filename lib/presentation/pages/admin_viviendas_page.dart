import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/vivienda/vivienda_bloc.dart';
import '../../domain/entities/vivienda_entity.dart';
import '../widgets/admin_scaffold.dart';

class AdminViviendasPage
    extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminViviendasPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminViviendasPage>
  createState() =>
      _AdminViviendasPageState();
}

class _AdminViviendasPageState
    extends State<AdminViviendasPage> {
  final _manzanaCtrl =
      TextEditingController();
  final _scrollController =
      ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController
        .addListener(_onScroll);
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<ViviendaBloc>()
          .add(const LoadViviendas());
    });
  }

  void _onScroll() {
    if (_scrollController
                .position.pixels >=
            _scrollController
                    .position
                    .maxScrollExtent -
                200) {
      final state = context
          .read<ViviendaBloc>()
          .state;
      if (state is ViviendaLoaded &&
          state.hasNext) {
        context
            .read<ViviendaBloc>()
            .add(const LoadMoreViviendas());
      }
    }
  }

  @override
  void dispose() {
    _manzanaCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _buscar() {
    context
        .read<ViviendaBloc>()
        .add(LoadViviendas(
      manzana: _manzanaCtrl
                  .text
                  .trim()
                  .isEmpty
              ? null
              : _manzanaCtrl.text
                  .trim(),
    ));
  }

  void _recargar() {
    context
        .read<ViviendaBloc>()
        .add(LoadViviendas(
      manzana: _manzanaCtrl
                  .text
                  .trim()
                  .isEmpty
              ? null
              : _manzanaCtrl.text
                  .trim(),
    ));
  }

  Future<void> _mostrarDialogoCrear() async {
    final mzCtrl =
        TextEditingController();
    final vlCtrl =
        TextEditingController();
    final formKey =
        GlobalKey<FormState>();

    final result =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
            'Nueva Vivienda'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextFormField(
                controller: mzCtrl,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Manzana',
                  hintText: 'Ej: 23',
                  border:
                      OutlineInputBorder(),
                ),
                textCapitalization:
                    TextCapitalization
                        .characters,
                validator: (v) =>
                    (v == null ||
                            v.trim()
                                .isEmpty)
                        ? 'Requerido'
                        : null,
              ),
              const SizedBox(
                  height: 16),
              TextFormField(
                controller: vlCtrl,
                decoration:
                    const InputDecoration(
                  labelText: 'Villa',
                  hintText: 'Ej: 11',
                  border:
                      OutlineInputBorder(),
                ),
                textCapitalization:
                    TextCapitalization
                        .characters,
                validator: (v) =>
                    (v == null ||
                            v.trim()
                                .isEmpty)
                        ? 'Requerido'
                        : null,
              ),
            ],
          ),
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
            onPressed: () {
              if (formKey
                          .currentState
                          ?.validate() ==
                      true) {
                Navigator.pop(
                    ctx, true);
              }
            },
            style: FilledButton
                .styleFrom(
                    backgroundColor:
                        const Color(
                            0xFF04345C)),
            child: const Text(
                'Crear'),
          ),
        ],
      ),
    );

    if (result == true &&
        context.mounted) {
      context
          .read<ViviendaBloc>()
          .add(CreateVivienda(
        manzana: mzCtrl.text
            .trim()
            .toUpperCase(),
        villa: vlCtrl.text
            .trim()
            .toUpperCase(),
      ));
    }
  }

  Future<void> _mostrarDialogoEditar(
      ViviendaEntity vivienda) async {
    final mzCtrl = TextEditingController(
        text: vivienda.manzana);
    final vlCtrl = TextEditingController(
        text: vivienda.villa);

    final result =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
            'Editar Vivienda'),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextFormField(
              controller: mzCtrl,
              decoration:
                  const InputDecoration(
                labelText: 'Manzana',
                border:
                    OutlineInputBorder(),
              ),
              textCapitalization:
                  TextCapitalization
                      .characters,
            ),
            const SizedBox(
                height: 16),
            TextFormField(
              controller: vlCtrl,
              decoration:
                  const InputDecoration(
                labelText: 'Villa',
                border:
                    OutlineInputBorder(),
              ),
              textCapitalization:
                  TextCapitalization
                      .characters,
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
                        const Color(
                            0xFF04345C)),
            child: const Text(
                'Guardar'),
          ),
        ],
      ),
    );

    if (result == true &&
        context.mounted) {
      context
          .read<ViviendaBloc>()
          .add(UpdateVivienda(
        viviendaId:
            vivienda.viviendaId,
        manzana: mzCtrl.text
            .trim()
            .toUpperCase(),
        villa: vlCtrl.text
            .trim()
            .toUpperCase(),
      ));
    }
  }

  Future<void> _confirmarToggle(
      ViviendaEntity vivienda) async {
    final activar =
        !vivienda.isActivo;
    final motivoCtrl =
        TextEditingController();

    final result =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(activar
            ? 'Activar Vivienda'
            : 'Desactivar Vivienda'),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(activar
                ? '¿Activar Mz ${vivienda.manzana}, V ${vivienda.villa}?'
                : '¿Desactivar Mz ${vivienda.manzana}, V ${vivienda.villa}?'),
            const SizedBox(
                height: 16),
            TextField(
              controller:
                  motivoCtrl,
              decoration:
                  const InputDecoration(
                labelText:
                    'Motivo (opcional)',
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
              backgroundColor: activar
                  ? Colors.green
                  : Colors.orange,
            ),
            child: Text(activar
                ? 'Activar'
                : 'Desactivar'),
          ),
        ],
      ),
    );

    if (result == true &&
        context.mounted) {
      context
          .read<ViviendaBloc>()
          .add(ToggleViviendaEstado(
        viviendaId:
            vivienda.viviendaId,
        estado: activar
            ? 'activo'
            : 'inactivo',
        motivo: motivoCtrl
                    .text
                    .trim()
                    .isEmpty
                ? null
                : motivoCtrl.text
                    .trim(),
      ));
    }
  }

  void _verDetalle(
      ViviendaEntity vivienda) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _ViviendaDetailPage(
          vivienda: vivienda,
          onEditar: () =>
              _mostrarDialogoEditar(
                  vivienda),
          onToggleEstado: () =>
              _confirmarToggle(
                  vivienda),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminScaffold(
      title:
          'Gestión de Viviendas',
      routeName:
          '/adminViviendas',
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
          onPressed:
              _mostrarDialogoCrear,
          icon: const Icon(
              Icons.add_home),
          label: const Text('Nueva'),
        ),
      ],
      body: BlocListener<ViviendaBloc,
          ViviendaState>(
        listener: (context,
            state) {
          if (state is ViviendaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Vivienda creada exitosamente'),
                  backgroundColor:
                      Colors.green),
            );
          } else if (state
              is ViviendaUpdated) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(
              const SnackBar(
                  content: Text(
                      'Vivienda actualizada'),
                  backgroundColor:
                      Colors.blue),
            );
          } else if (state
              is ViviendaEstadoChanged) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(
              SnackBar(
                content: Text(
                    state.mensaje),
                backgroundColor: state
                            .nuevoEstado ==
                        'activo'
                    ? Colors.green
                    : Colors.orange,
              ),
            );
          } else if (state is ViviendaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.mensaje), backgroundColor: Colors.red),
            );
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
                            'Buscar por manzana',
                        prefixIcon: const Icon(
                            Icons
                                .search),
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
                      onSubmitted:
                          (_) =>
                              _buscar(),
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
                    child: const Text(
                        'Buscar'),
                  ),
                ],
              ),
            ),
            const Divider(
                height: 1),
            Expanded(
              child: BlocBuilder<
                  ViviendaBloc,
                  ViviendaState>(
                builder: (context,
                    state) {
                  if (state
                      is ViviendaLoading) {
                    return const Center(
                        child:
                            CircularProgressIndicator());
                  }

                  if (state is ViviendaError) {
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
                                  .mensaje,
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
                      is ViviendaInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons
                                .home_work,
                            size: 64,
                            color: Colors
                                .grey
                                .shade400,
                          ),
                          const SizedBox(
                              height:
                                  16),
                          Text(
                            'Busca o lista las viviendas',
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
                      is ViviendaLoaded) {
                    if (state
                        .viviendas
                        .isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .home_work,
                              size: 64,
                              color: Colors
                                  .grey
                                  .shade400,
                            ),
                            const SizedBox(
                                height:
                                    16),
                            const Text(
                              'No se encontraron viviendas',
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
                        controller:
                            _scrollController,
                        padding:
                            const EdgeInsets.all(16),
                        itemCount: state
                            .viviendas
                            .length,
                        itemBuilder: (context,
                            index) {
                          final v = state
                              .viviendas[
                              index];
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
                                backgroundColor: v.isActivo
                                    ? Colors
                                        .teal
                                        .withOpacity(0.15)
                                    : Colors
                                        .orange
                                        .withOpacity(0.15),
                                child: Icon(
                                  Icons
                                      .home,
                                  color: v.isActivo
                                      ? Colors
                                          .teal
                                      : Colors
                                          .orange,
                                ),
                              ),
                              title: Text(
                                'Mz ${v.manzana}, Villa ${v.villa}',
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${v.totalResidentes} residentes · ${v.totalMiembros} miembros',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                              trailing: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  if (!v.isActivo)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Inactiva',
                                        style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () =>
                                  _verDetalle(v),
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

class _ViviendaDetailPage
    extends StatelessWidget {
  final ViviendaEntity vivienda;
  final VoidCallback onEditar;
  final VoidCallback onToggleEstado;

  const _ViviendaDetailPage({
    required this.vivienda,
    required this.onEditar,
    required this.onToggleEstado,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Detalle de Vivienda'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(
                      Icons.edit,
                      color:
                          Colors.blue),
                  title:
                      Text('Editar'),
                  contentPadding:
                      EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: ListTile(
                  leading: Icon(
                    vivienda.isActivo
                        ? Icons.block
                        : Icons
                            .check_circle,
                    color: vivienda
                            .isActivo
                        ? Colors.orange
                        : Colors.green,
                  ),
                  title: Text(vivienda
                          .isActivo
                      ? 'Desactivar'
                      : 'Activar'),
                  contentPadding:
                      EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (action) {
              switch (action) {
                case 'edit':
                  onEditar();
                case 'toggle':
                  onToggleEstado();
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
            child:
                Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors
                    .teal
                    .withOpacity(0.15),
                child: const Icon(
                    Icons.home,
                    size: 36,
                    color:
                        Colors.teal),
              ),
              const SizedBox(
                  height: 12),
              Text(
                'Mz ${vivienda.manzana}, Villa ${vivienda.villa}',
                style: theme
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                        fontWeight:
                            FontWeight
                                .bold),
              ),
              const SizedBox(
                  height: 4),
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color: vivienda
                          .isActivo
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
                  vivienda.isActivo
                      ? 'Activa'
                      : 'Inactiva',
                  style: TextStyle(
                    color: vivienda
                            .isActivo
                        ? Colors.green
                        : Colors.orange,
                    fontWeight:
                        FontWeight
                            .bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 32),
          _sectionTitle(context,
              'Información'),
          const SizedBox(height: 12),
          _detailCard(context, [
            _DetailField('Manzana',
                vivienda.manzana),
            _DetailField('Villa',
                vivienda.villa),
            _DetailField(
              'Estado',
              vivienda.isActivo
                  ? 'Activa'
                  : 'Inactiva',
            ),
            _DetailField(
              'Residentes',
              '${vivienda.totalResidentes}',
            ),
            _DetailField(
              'Miembros',
              '${vivienda.totalMiembros}',
            ),
            _DetailField(
              'Creada',
              vivienda
                      .fechaCreado !=
                  null
                  ? '${vivienda.fechaCreado!.day}/${vivienda.fechaCreado!.month}/${vivienda.fechaCreado!.year}'
                  : '—',
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  onToggleEstado,
              icon: Icon(
                vivienda.isActivo
                    ? Icons.block
                    : Icons
                        .check_circle,
                color: vivienda
                        .isActivo
                    ? Colors.orange
                    : Colors.green,
              ),
              label: Text(
                vivienda.isActivo
                    ? 'Desactivar vivienda'
                    : 'Activar vivienda',
                style: TextStyle(
                    color: vivienda
                            .isActivo
                        ? Colors.orange
                        : Colors.green),
              ),
              style: OutlinedButton
                  .styleFrom(
                side: BorderSide(
                    color: vivienda
                            .isActivo
                        ? Colors.orange
                        : Colors.green),
                padding:
                    const EdgeInsets
                        .symmetric(
                        vertical:
                            16),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                            f.value,
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
  final String value;
  const _DetailField(
      this.label, this.value);
}
