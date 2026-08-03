import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/vivienda/vivienda_bloc.dart';
import '../../application/blocs/owner/owner_bloc.dart';
import '../widgets/admin_scaffold.dart';
import 'admin_manzana_villas_page.dart';

class AdminViviendasPage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminViviendasPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminViviendasPage> createState() =>
      _AdminViviendasPageState();
}

class _AdminViviendasPageState
    extends State<AdminViviendasPage> {
  final _busquedaCtrl =
      TextEditingController();
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<ViviendaBloc>()
          .add(const LoadManzanas());
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  List<ManzanaResumen> _filtrar(
      List<ManzanaResumen> lista) {
    if (_busqueda.isEmpty) return lista;
    return lista
        .where((m) => m.manzana
            .toLowerCase()
            .contains(
                _busqueda.toLowerCase()))
        .toList();
  }

  Future<void> _mostrarDialogoCrearManzana() async {
    final mzCtrl =
        TextEditingController();
    final cantCtrl =
        TextEditingController();
    final formKey =
        GlobalKey<FormState>();

    final result =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
            'Crear Manzana'),
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
                      'Número de Manzana',
                  hintText: 'Ej: 25',
                  border:
                      OutlineInputBorder(),
                ),
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
                controller:
                    cantCtrl,
                keyboardType:
                    TextInputType
                        .number,
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly,
                ],
                decoration:
                    const InputDecoration(
                  labelText:
                      'Número de villas',
                  hintText: 'Ej: 20',
                  helperText:
                      'Se crearán villas del 1 al N',
                  border:
                      OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null ||
                      v.isEmpty) {
                    return 'Requerido';
                  }
                  final n =
                      int.tryParse(v);
                  if (n == null ||
                      n < 1) {
                    return 'Mínimo 1';
                  }
                  if (n > 50) {
                    return 'Máximo 50';
                  }
                  return null;
                },
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
                'Crear Manzana'),
          ),
        ],
      ),
    );

    if (result == true &&
        context.mounted) {
      final manzana = mzCtrl.text
          .trim()
          .toUpperCase();
      final cantidad =
          int.tryParse(
                  cantCtrl.text) ??
              1;
      context
          .read<ViviendaBloc>()
          .add(CreateBulkViviendas(
            manzana: manzana,
            cantidad: cantidad,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminScaffold(
      title: 'Gestión de Viviendas',
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
        if (i == 4) return;
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          final routes = [
            '/adminDashboard',
            // TODO: Restaurar cuando se implemente el módulo de historial
            // '/adminAccessHistory',
            '/adminUsers',
            '/adminProfile',
            '/adminNotificaciones',
            null,
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
              _mostrarDialogoCrearManzana,
          icon: const Icon(
              Icons.add_home),
          label: const Text(
              'Crear Manzana'),
        ),
      ],
      body: BlocListener<ViviendaBloc,
          ViviendaState>(
        listener: (context,
            state) {
          if (state
              is ViviendasBulkCreated) {
            final omitidas = state
                    .omitidas
                    .isNotEmpty
                ? '. Omitidas: ${state.omitidas.join(', ')}'
                : '';
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(
              SnackBar(
                content: Text(
                    'Manzana ${state.manzana}: ${state.creadas} villas creadas$omitidas'),
                backgroundColor: state
                        .omitidas
                        .isEmpty
                    ? Colors.green
                    : Colors.orange,
              ),
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets
                      .all(16),
              child: TextField(
                controller:
                    _busquedaCtrl,
                onChanged: (v) =>
                    setState(() =>
                        _busqueda =
                            v),
                decoration:
                    InputDecoration(
                  hintText:
                      'Buscar manzana...',
                  prefixIcon: const Icon(
                      Icons.search),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                12),
                  ),
                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
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
                      is ManzanasLoading) {
                    return const Center(
                        child:
                            CircularProgressIndicator());
                  }

                  if (state is ViviendaError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(state.mensaje,
                              style: TextStyle(color: Colors.red[700], fontSize: 16)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ViviendaBloc>().add(const LoadManzanas());
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state
                      is ManzanasError) {
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
                          Text(state
                              .message),
                          const SizedBox(
                              height:
                                  16),
                          ElevatedButton
                              .icon(
                            onPressed:
                                () => context
                                    .read<
                                        ViviendaBloc>()
                                    .add(const LoadManzanas()),
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
                      is ManzanasLoaded) {
                    final filtradas =
                        _filtrar(state
                            .manzanas);

                    if (filtradas
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
                              'No se encontraron manzanas',
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
                          context
                              .read<ViviendaBloc>()
                              .add(const LoadManzanas()),
                      child: ListView
                          .builder(
                        padding:
                            const EdgeInsets.all(16),
                        itemCount:
                            filtradas.length,
                        itemBuilder: (context,
                            index) {
                          final m =
                              filtradas[
                                  index];
                          return Card(
                            margin: const EdgeInsets
                                .only(
                                bottom:
                                    12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16)),
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(16),
                              onTap: () async {
                                final viviendaBloc =
                                    context.read<ViviendaBloc>();
                                final ownerBloc =
                                    context.read<OwnerBloc>();
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: viviendaBloc,
                                      child: BlocProvider.value(
                                        value: ownerBloc,
                                        child: AdminManzanaVillasPage(
                                          manzana: m.manzana,
                                          personaId: widget.personaId,
                                          identificacion: widget.identificacion,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                                if (!mounted) return;
                                viviendaBloc.add(const LoadManzanas());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.apartment, color: Colors.teal, size: 28),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Manzana ${m.manzana}',
                                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${m.totalVillas} villas',
                                                style: TextStyle(color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, color: Colors.grey),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _statChip(Icons.check_circle, Colors.green, '${m.villasActivas} activas'),
                                        const SizedBox(width: 8),
                                        _statChip(Icons.block, Colors.orange, '${m.villasInactivas} inactivas'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '👤 ${m.totalPropietarios} propietarios · 👥 ${m.totalResidentes} residentes · 👨‍👩‍👧 ${m.totalMiembros} miembros',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
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
      ),
    );
  }

  Widget _statChip(IconData icon,
      Color color, String label) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            color.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
