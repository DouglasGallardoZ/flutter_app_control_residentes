import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/owner/owner_bloc.dart';
import '../../application/blocs/owner/owner_event.dart';
import '../../application/blocs/owner/owner_state.dart';
import '../../domain/entities/owner_entity.dart';
import '../widgets/admin_scaffold.dart';

class AdminOwnersPage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminOwnersPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminOwnersPage> createState() => _AdminOwnersPageState();
}

class _AdminOwnersPageState extends State<AdminOwnersPage> {
  final TextEditingController _manzanaController = TextEditingController();
  final TextEditingController _villaController = TextEditingController();
  
  // Guardar la última búsqueda
  String? _lastManzana;
  String? _lastVilla;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _manzanaController.dispose();
    _villaController.dispose();
    super.dispose();
  }



  void _handleFilterByLocation() {
    final manzana = _manzanaController.text.trim();
    final villa = _villaController.text.trim();

    if (manzana.isEmpty || villa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa manzana y villa')),
      );
      return;
    }

    // Guardar los parámetros de búsqueda
    _lastManzana = manzana;
    _lastVilla = villa;

    context.read<OwnerBloc>().add(LoadOwnersByLocationEvent(
      manzana: manzana,
      villa: villa,
    ));
  }

  void _clearFilters() {
    _manzanaController.clear();
    _villaController.clear();
    _lastManzana = null;
    _lastVilla = null;
  }

  void _reloadOwnersFromLastSearch() {
    if (_lastManzana != null && _lastVilla != null) {
      context.read<OwnerBloc>().add(LoadOwnersByLocationEvent(
        manzana: _lastManzana!,
        villa: _lastVilla!,
      ));
    }
  }

  void _showOwnerDetails(OwnerEntity owner) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: owner.isBlocked ? Colors.red.shade200 : Colors.blue.shade200,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: owner.isBlocked ? Colors.red.shade700 : Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        owner.nombreCompleto,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'M${owner.manzana} - V${owner.villa}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailItem(label: 'Identificación', value: owner.identificacion),
              _DetailItem(label: 'Email', value: owner.correo),
              _DetailItem(label: 'Celular', value: owner.celular),
              _DetailItem(label: 'Ubicación', value: '${owner.manzana} - ${owner.villa}'),
              _DetailItem(
                label: 'Estado',
                value: owner.isBlocked ? 'Bloqueado' : 'Activo',
                valueColor: owner.isBlocked ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBlockDialog(owner);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          owner.isBlocked ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Text(owner.isBlocked ? 'Desbloquear' : 'Bloquear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteDialog(owner);
                      },
                      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
                      child: const Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockDialog(OwnerEntity owner) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(owner.isBlocked ? 'Desbloquear Propietario' : 'Bloquear Propietario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Propietario: ${owner.nombreCompleto}'),
              const SizedBox(height: 16),
              const Text('Motivo (obligatorio):'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: owner.isBlocked ? 'Motivo de desbloqueo' : 'Motivo de bloqueo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El motivo es obligatorio'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              if (owner.isBlocked) {
                context.read<OwnerBloc>().add(UnblockOwnerEvent(owner.id, reason));
              } else {
                context.read<OwnerBloc>().add(BlockOwnerEvent(owner.id, reason));
              }
            },
            child: Text(owner.isBlocked ? 'Desbloquear' : 'Bloquear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(OwnerEntity owner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Propietario'),
        content: Text('¿Está seguro de eliminar a ${owner.nombreCompleto}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<OwnerBloc>().add(DeleteOwnerEvent(owner.id));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showPropertiesDialog(OwnerEntity owner) {
    context.read<OwnerBloc>().add(GetOwnerPropertiesEvent(owner.id));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Propiedades de ${owner.nombreCompleto}'),
        content: BlocBuilder<OwnerBloc, OwnerState>(
          builder: (context, state) {
            if (state is OwnerPropertiesLoaded) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: state.properties
                      .map((prop) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.home, color: Colors.blue),
                              title: Text(prop['nombre'] ?? 'N/A'),
                              subtitle: Text('${prop['residente_count'] ?? 0} residentes • ${prop['estado'] ?? 'N/A'}'),
                            ),
                          ))
                      .toList(),
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Gestión de Propietarios',
      routeName: '/adminOwners',
      showBackButton: true,
      onBackPressed: () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/adminUsers',
          (route) => false,
          arguments: {
            'personaId': widget.personaId,
            'identificacion': widget.identificacion,
          },
        );
      },
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/adminCreateOwner',
                  arguments: {
                    'personaId': widget.personaId,
                    'identificacion': widget.identificacion,
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Registrar'),
            ),
          ),
        ),
      ],
      body: BlocListener<OwnerBloc, OwnerState>(
        listener: (context, state) {
          if (state is OwnerBlocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            _reloadOwnersFromLastSearch();
          } else if (state is OwnerUnblocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _reloadOwnersFromLastSearch();
          } else if (state is OwnerDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            _reloadOwnersFromLastSearch();
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manzanaController,
                          decoration: InputDecoration(
                            hintText: 'Manzana',
                            prefixIcon: const Icon(Icons.home),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _villaController,
                          decoration: InputDecoration(
                            hintText: 'Villa',
                            prefixIcon: const Icon(Icons.apartment),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: _handleFilterByLocation,
                        child: const Text('Buscar por Ubicación'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpiar filtros',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<OwnerBloc, OwnerState>(
              builder: (context, state) {
                if (state is OwnerLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OwnerError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => context.read<OwnerBloc>().add(LoadOwnersByLocationEvent(
                            manzana: _manzanaController.text.trim(),
                            villa: _villaController.text.trim(),
                          )),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OwnersByLocationLoaded && state.owners.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay propietarios en esa ubicación'),
                      ],
                    ),
                  );
                }

                if (state is OwnerInitial) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Busca propietarios por manzana y villa'),
                      ],
                    ),
                  );
                }

                final owners = (state is OwnersByLocationLoaded ? state.owners : <OwnerEntity>[]);

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: owners.length,
                  itemBuilder: (context, index) {
                    final owner = owners[index];
                    return _OwnerCard(
                      owner: owner,
                      onTap: () => _showOwnerDetails(owner),
                      onBlock: () => _showBlockDialog(owner),
                      onDelete: () => _showDeleteDialog(owner),
                    );
                  },
                );
              },
            ),
          ),
            ],
          ),
        ),
      );
  }
}

class _OwnerCard extends StatelessWidget {
  final OwnerEntity owner;
  final VoidCallback onTap;
  final VoidCallback onBlock;
  final VoidCallback onDelete;

  const _OwnerCard({
    required this.owner,
    required this.onTap,
    required this.onBlock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: owner.isBlocked ? Colors.red.shade200 : Colors.blue.shade200,
          child: Icon(
            Icons.person,
            color: owner.isBlocked ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(owner.nombreCompleto),
        subtitle: Text('${owner.manzana} - ${owner.villa}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (owner.isBlocked)
              Chip(
                label: const Text('Bloqueado', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.red.shade100,
                labelStyle: TextStyle(color: Colors.red.shade700),
                side: BorderSide(color: Colors.red.shade300),
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(onTap: onTap, child: const Text('Ver detalles')),
                PopupMenuItem(
                  onTap: onBlock,
                  child: Text(owner.isBlocked ? 'Desbloquear' : 'Bloquear'),
                ),
                PopupMenuItem(
                  onTap: onDelete,
                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: valueColor ?? Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
