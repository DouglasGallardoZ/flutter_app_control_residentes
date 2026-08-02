import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/vivienda/vivienda_bloc.dart';
import '../../application/blocs/owner/owner_bloc.dart';
import '../../application/blocs/owner/owner_event.dart';
import '../../domain/entities/vivienda_entity.dart';
import '../../domain/ports/vivienda_repository_port.dart';
import '../../injection.dart';
import 'admin_create_owner_page.dart';
import 'admin_villa_detalle_page.dart';

class AdminManzanaVillasPage extends StatefulWidget {
  final String manzana;
  final int personaId;
  final String identificacion;

  const AdminManzanaVillasPage({
    super.key,
    required this.manzana,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminManzanaVillasPage> createState() =>
      _AdminManzanaVillasPageState();
}

class _AdminManzanaVillasPageState
    extends State<AdminManzanaVillasPage> {
  final _villaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViviendaBloc>().add(
          LoadViviendas(manzana: widget.manzana));
    });
  }

  @override
  void dispose() {
    _villaCtrl.dispose();
    super.dispose();
  }

  void _recargar() {
    context.read<ViviendaBloc>().add(
        LoadViviendas(manzana: widget.manzana));
  }

  Future<void> _mostrarDialogoAgregarVilla() async {
    _villaCtrl.clear();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Villa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Manzana: ${widget.manzana}',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: _villaCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'Número de Villa',
                  hintText: 'Ej: 21',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF04345C)),
            child: const Text('Agregar Villa'),
          ),
        ],
      ),
    );

    if (confirmado == true && _villaCtrl.text.isNotEmpty && context.mounted) {
      context.read<ViviendaBloc>().add(CreateVivienda(
            manzana: widget.manzana,
            villa: _villaCtrl.text.trim(),
          ));
    }
  }

  Future<void> _mostrarDialogoCambioPropietario(
      ViviendaEntity vivienda) async {
    final viviendaBloc = context.read<ViviendaBloc>();
    final viviendaRepo = sl<ViviendaRepositoryPort>();

    void recargar() {
      if (mounted) {
        viviendaBloc.add(LoadViviendas(manzana: widget.manzana));
      }
    }

    await showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: viviendaBloc,
        child: _ChangeOwnerDialog(
          viviendaId: vivienda.viviendaId,
          manzana: vivienda.manzana,
          villaNum: vivienda.villa,
          propietarioActual: vivienda.propietarios.isNotEmpty
              ? vivienda.propietarios.first.nombreCompleto
              : null,
          repository: viviendaRepo,
          onOwnerChanged: recargar,
        ),
      ),
    );
  }

  Future<void> _confirmarToggleEstado(
      ViviendaEntity vivienda) async {
    final activar = !vivienda.isActivo;
    final viviendaBloc = context.read<ViviendaBloc>();
    final motivoCtrl = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(activar ? 'Activar Villa' : 'Desactivar Villa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(activar
                ? '¿Activar Mz ${vivienda.manzana}, V ${vivienda.villa}?'
                : '¿Desactivar Mz ${vivienda.manzana}, V ${vivienda.villa}?'),
            const SizedBox(height: 16),
            TextField(
              controller: motivoCtrl,
              decoration: const InputDecoration(
                  labelText: 'Motivo', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: activar ? Colors.green : Colors.orange),
            child: Text(activar ? 'Activar' : 'Desactivar'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmado == true) {
      viviendaBloc.add(ToggleViviendaEstado(
            viviendaId: vivienda.viviendaId,
            estado: activar ? 'activo' : 'inactivo',
            motivo: motivoCtrl.text.trim(),
          ));
    }
    motivoCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manzana ${widget.manzana}'),
      ),
      body: BlocListener<ViviendaBloc, ViviendaState>(
        listener: (context, state) {
          if (state is ViviendaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Villa creada'),
                  backgroundColor: Colors.green),
            );
            _recargar();
          } else if (state is ViviendaEstadoChanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: state.nuevoEstado == 'activo'
                    ? Colors.green
                    : Colors.orange,
              ),
            );
            _recargar();
          } else if (state is PropietarioCambiado) {
            // El diálogo ya muestra el SnackBar de éxito.
            // Solo recargar la lista.
            _recargar();
          } else if (state is ViviendaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ViviendaBloc, ViviendaState>(
                builder: (context, state) {
                  if (state is ViviendaLoading) {
                    return const Center(child: CircularProgressIndicator());
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
                              context.read<ViviendaBloc>().add(
                                  LoadViviendas(manzana: widget.manzana));
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ViviendaLoaded) {
                    if (state.viviendas.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text('No hay villas en esta manzana'),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _recargar(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.viviendas.length,
                        itemBuilder: (context, index) {
                          final v = state.viviendas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: v.isActivo
                                    ? Colors.teal.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                child: Icon(Icons.home,
                                    color: v.isActivo ? Colors.teal : Colors.orange),
                              ),
                              title: Text('Villa ${v.villa}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (v.propietarios.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 14, color: Colors.blueGrey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            v.propietarios.first.nombreCompleto,
                                            style: const TextStyle(fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (v.propietarios.first.tipo == 'titular')
                                          Container(
                                            margin: const EdgeInsets.only(left: 4),
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('Titular', style: TextStyle(fontSize: 10, color: Colors.blue)),
                                          ),
                                      ],
                                    )
                                  else
                                    const Row(
                                      children: [
                                        Icon(Icons.person_off, size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text('Sin propietario', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.people, size: 14, color: Colors.blueGrey),
                                      const SizedBox(width: 4),
                                      Text('${v.totalResidentes} res · ${v.totalMiembros} miem',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: v.isActivo
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: v.isActivo
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                    child: Text(
                                      v.isActivo ? 'Activa' : 'Inactiva',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: v.isActivo
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  PopupMenuButton<String>(
                                    onSelected: (opcion) {
                                      switch (opcion) {
                                        case 'cambiar_propietario':
                                          _mostrarDialogoCambioPropietario(v);
                                        case 'toggle':
                                          _confirmarToggleEstado(v);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'cambiar_propietario',
                                        child: ListTile(
                                          leading: Icon(Icons.swap_horiz,
                                              size: 20,
                                              color: Color(0xFF04345C)),
                                          title: Text('Cambiar Propietario'),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle',
                                        child: ListTile(
                                          leading: Icon(
                                            v.isActivo
                                                ? Icons.block
                                                : Icons.check_circle,
                                            size: 20,
                                            color: v.isActivo
                                                ? Colors.orange
                                                : Colors.green,
                                          ),
                                          title: Text(v.isActivo
                                              ? 'Desactivar'
                                              : 'Activar'),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final viviendaBloc =
                                    context.read<ViviendaBloc>();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: viviendaBloc,
                                      child: AdminVillaDetallePage(
                                        viviendaId: v.viviendaId,
                                        manzana: v.manzana,
                                        villa: v.villa,
                                      ),
                                    ),
                                  ),
                                );
                                if (!mounted) return;
                                viviendaBloc.add(
                                    LoadViviendas(manzana: widget.manzana));
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }

                  if (state is ViviendaInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoAgregarVilla,
        icon: const Icon(Icons.add),
        label: const Text('Agregar Villa'),
        backgroundColor: const Color(0xFF04345C),
      ),
    );
  }
}

class _ChangeOwnerDialog extends StatefulWidget {
  final int viviendaId;
  final String manzana;
  final String villaNum;
  final String? propietarioActual;
  final ViviendaRepositoryPort repository;
  final VoidCallback onOwnerChanged;
  final Map<String, dynamic>? personaPrecargada;

  const _ChangeOwnerDialog({
    required this.viviendaId,
    required this.manzana,
    required this.villaNum,
    this.propietarioActual,
    required this.repository,
    required this.onOwnerChanged,
    this.personaPrecargada,
  });

  @override
  State<_ChangeOwnerDialog> createState() =>
      _ChangeOwnerDialogState();
}

class _ChangeOwnerDialogState
    extends State<_ChangeOwnerDialog> {
  final _cedulaCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();
  bool _buscando = false;
  bool _asignando = false;
  Map<String, dynamic>? _personaEncontrada;
  String? _error;
  String _tipo = 'titular';
  bool _confirmado = false;

  bool get _formValido =>
      _personaEncontrada != null &&
      _motivoCtrl.text.trim().isNotEmpty &&
      _confirmado;

  @override
  void initState() {
    super.initState();
    if (widget.personaPrecargada != null) {
      _personaEncontrada = widget.personaPrecargada;
      _cedulaCtrl.text =
          _personaEncontrada!['identificacion']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscarPersona() async {
    final cedula = _cedulaCtrl.text.trim();
    if (cedula.length < 10) {
      setState(() => _error = 'Ingrese una cédula válida (10 dígitos)');
      return;
    }
    setState(() {
      _buscando = true;
      _error = null;
      _personaEncontrada = null;
    });
    try {
      final response = await widget.repository.buscarPersonaPorCedula(cedula);
      if (!mounted) return;
      setState(() {
        _buscando = false;
        _personaEncontrada = response;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _buscando = false;
        _error = 'Error al buscar: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _registrarNuevoPropietario() async {
    final cedula = _cedulaCtrl.text.trim();
    Navigator.pop(context);

    final nuevoPropietario =
        await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminCreateOwnerPage(
          personaId: 0,
          identificacion: '',
          cedula: cedula,
          manzana: widget.manzana,
          villa: widget.villaNum,
          fromChangeOwner: true,
        ),
      ),
    );

    if (nuevoPropietario != null && mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => BlocProvider.value(
          value: context.read<ViviendaBloc>(),
          child: _ChangeOwnerDialog(
            viviendaId: widget.viviendaId,
            manzana: widget.manzana,
            villaNum: widget.villaNum,
            propietarioActual: widget.propietarioActual,
            personaPrecargada: nuevoPropietario,
            repository: widget.repository,
            onOwnerChanged: widget.onOwnerChanged,
          ),
        ),
      );
    }
  }

  Future<void> _asignarPropietario() async {
    if (!_formValido || _asignando) return;
    final personaId = _personaEncontrada!['persona_id'] ??
        _personaEncontrada!['id'];
    setState(() {
      _asignando = true;
      _error = null;
    });

    try {
      await widget.repository.cambiarPropietario(
        viviendaId: widget.viviendaId,
        nuevoPropietarioId: personaId is int
            ? personaId
            : int.tryParse(personaId.toString()) ?? 0,
        tipo: _tipo,
        motivo: _motivoCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Propietario asignado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onOwnerChanged();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _asignando = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mostrarResultado =
        _personaEncontrada != null ||
        (_cedulaCtrl.text.trim().length >= 10 &&
            !_buscando &&
            _error == null &&
            widget.personaPrecargada == null);

    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cambiar Propietario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                  'Manzana ${widget.manzana} - Villa ${widget.villaNum}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              if (widget.propietarioActual != null) ...[
                const SizedBox(height: 4),
                Text('Actual: ${widget.propietarioActual}',
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cedulaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Identificación',
                        hintText: '0912345678',
                        border: const OutlineInputBorder(),
                        prefixIcon:
                            const Icon(Icons.badge_outlined),
                        errorText: _error,
                      ),
                      onSubmitted: (_) => _buscarPersona(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _buscando ? null : _buscarPersona,
                      icon: _buscando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_personaEncontrada != null) ...[
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.primaryColor,
                    child: const Icon(Icons.person,
                        color: Colors.white),
                  ),
                  title: Text(
                    '${_personaEncontrada!['nombres'] ?? ''} '
                    '${_personaEncontrada!['apellidos'] ?? ''}'
                        .trim(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${_personaEncontrada!['identificacion'] ?? ''}'
                    '${_personaEncontrada!['correo'] != null ? ' · ${_personaEncontrada!['correo']}' : ''}',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'titular', child: Text('Titular')),
                    DropdownMenuItem(
                        value: 'copropietario',
                        child: Text('Copropietario')),
                  ],
                  onChanged: (v) =>
                      setState(() => _tipo = v ?? 'titular'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _motivoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Motivo del cambio *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _confirmado,
                  onChanged: (v) =>
                      setState(() => _confirmado = v ?? false),
                  title: const Text(
                      'Confirmo el cambio de propietario'),
                  controlAffinity:
                      ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],

              if (mostrarResultado &&
                  _personaEncontrada == null &&
                  widget.personaPrecargada == null) ...[
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.person_off,
                          color: Colors.orange, size: 40),
                      const SizedBox(height: 8),
                      const Text('Persona no encontrada',
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text(
                          'La cédula no está registrada en el sistema.',
                          style: TextStyle(fontSize: 13)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              _registrarNuevoPropietario,
                          icon: const Icon(Icons.person_add),
                          label: const Text(
                              'Registrar nuevo propietario'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  if (_personaEncontrada != null)
                    ElevatedButton(
                      onPressed: (_formValido && !_asignando)
                          ? _asignarPropietario
                          : null,
                      child: _asignando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Asignar Propietario'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CambioPropietarioData {
  final int viviendaId;
  final int nuevoPropietarioId;
  final String tipo;
  final String motivo;

  CambioPropietarioData({
    required this.viviendaId,
    required this.nuevoPropietarioId,
    required this.tipo,
    required this.motivo,
  });

}
