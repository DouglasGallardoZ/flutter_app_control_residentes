import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  State<AdminMembersPage> createState() => _AdminMembersPageState();
}

class _AdminMembersPageState extends State<AdminMembersPage> {
  final TextEditingController _manzanaController = TextEditingController();
  final TextEditingController _villaController = TextEditingController();

  // Guardar la última búsqueda
  String? _lastManzana;
  String? _lastVilla;

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

    context.read<MemberBloc>().add(LoadMembersByLocationEvent(
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

  void _reloadMembersFromLastSearch() {
    if (_lastManzana != null && _lastVilla != null) {
      context.read<MemberBloc>().add(LoadMembersByLocationEvent(
        manzana: _lastManzana!,
        villa: _lastVilla!,
      ));
    }
  }

  void _showMemberDetails(Map<String, dynamic> member) {
    final nombres = member['nombres'] ?? '';
    final apellidos = member['apellidos'] ?? '';
    final nombreCompleto = '$nombres $apellidos'.trim();
    final relacion = member['parentesco'] ?? '';
    final manzana = member['manzana'] ?? '';
    final villa = member['villa'] ?? '';
    final estado = member['estado'] ?? 'activo';
    final isBlocked = estado.toLowerCase() == 'inactivo';

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
                    backgroundColor: isBlocked ? Colors.red.shade200 : Colors.pink.shade200,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: isBlocked ? Colors.red.shade700 : Colors.pink.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreCompleto,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          relacion,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailItem(label: 'Email', value: member['correo'] ?? 'N/A'),
              _DetailItem(label: 'Relación', value: relacion),
              _DetailItem(label: 'Identificación', value: member['identificacion'] ?? 'N/A'),
              _DetailItem(label: 'Teléfono', value: member['celular'] ?? 'N/A'),
              _DetailItem(label: 'Ubicación', value: '$manzana - $villa'),
              _DetailItem(
                label: 'Estado',
                value: estado[0].toUpperCase() + estado.substring(1),
                valueColor: isBlocked ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBlockDialog(member, nombreCompleto, isBlocked);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isBlocked ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Text(isBlocked ? 'Reactivar' : 'Desactivar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteDialog(member, nombreCompleto);
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

  void _showBlockDialog(Map<String, dynamic> member, String nombreCompleto, bool isBlocked) {
    final TextEditingController reasonController = TextEditingController();
    final memberId = member['miembro_id'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBlocked ? 'Reactivar miembro' : 'Desactivar miembro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Miembro: $nombreCompleto'),
              const SizedBox(height: 16),
              const Text('Motivo (obligatorio):'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: isBlocked ? 'Motivo de reactivación' : 'Motivo de desactivación',
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
            onPressed: () {
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
              if (isBlocked) {
                context.read<MemberBloc>().add(ReactivateMemberEvent(
                  memberId: memberId,
                  reason: reason,
                ));
              } else {
                context.read<MemberBloc>().add(DeactivateMemberEvent(
                  memberId: memberId,
                  reason: reason,
                ));
              }
            },
            child: Text(isBlocked ? 'Reactivar' : 'Desactivar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> member, String nombreCompleto) {
    final memberId = member['miembro_id'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text(
          '¿Desea eliminar la cuenta de $nombreCompleto? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              context.read<MemberBloc>().add(DeleteMemberEvent(memberId));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Gestión de Miembros',
      routeName: '/adminMembers',
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
      actions: [],
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
          }
        });
      },
      body: BlocListener<MemberBloc, MemberState>(
        listener: (context, state) {
          if (state is MemberDeactivated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            _reloadMembersFromLastSearch();
          } else if (state is MemberReactivated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _reloadMembersFromLastSearch();
          } else if (state is MemberDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            _reloadMembersFromLastSearch();
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _villaController,
                          decoration: InputDecoration(
                            hintText: 'Villa',
                            prefixIcon: const Icon(Icons.apartment),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
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
                          child: const Text('Buscar Miembros'),
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
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<MemberBloc, MemberState>(
                builder: (context, state) {
                  if (state is MemberLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando miembros...'),
                        ],
                      ),
                    );
                  }

                  if (state is MemberError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonal(
                            onPressed: _handleFilterByLocation,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MemberInitial) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Busca miembros por manzana y villa'),
                        ],
                      ),
                    );
                  }

                  if (state is MembersByLocationLoaded && state.members.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No se encontraron miembros'),
                        ],
                      ),
                    );
                  }

                  final members = (state is MembersByLocationLoaded ? state.members : <Map<String, dynamic>>[]);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return _MemberCard(
                        member: member,
                        onDetails: () => _showMemberDetails(member),
                        onBlock: () {
                          final nombres = member['nombres'] ?? '';
                          final apellidos = member['apellidos'] ?? '';
                          final nombreCompleto = '$nombres $apellidos'.trim();
                          final estado = member['estado'] ?? 'activo';
                          final isBlocked = estado.toLowerCase() == 'inactivo';
                          _showBlockDialog(member, nombreCompleto, isBlocked);
                        },
                        onDelete: () {
                          final nombres = member['nombres'] ?? '';
                          final apellidos = member['apellidos'] ?? '';
                          final nombreCompleto = '$nombres $apellidos'.trim();
                          _showDeleteDialog(member, nombreCompleto);
                        },
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

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onBlock;
  final VoidCallback onDelete;
  final VoidCallback onDetails;

  const _MemberCard({
    required this.member,
    required this.onBlock,
    required this.onDelete,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final nombres = member['nombres'] ?? '';
    final apellidos = member['apellidos'] ?? '';
    final nombreCompleto = '$nombres $apellidos'.trim();
    final relacion = member['parentesco'] ?? '';
    final manzana = member['manzana'] ?? '';
    final villa = member['villa'] ?? '';
    final estado = member['estado'] ?? 'activo';
    final isBlocked = estado.toLowerCase() == 'inactivo';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBlocked ? Colors.red.shade200 : Colors.pink.shade200,
          child: Icon(
            Icons.person,
            color: isBlocked ? Colors.red : Colors.pink,
          ),
        ),
        title: Text(nombreCompleto),
        subtitle: Text('$relacion • $manzana - $villa'),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (isBlocked)
              Chip(
                label: const Text('Inactivo', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.red.shade100,
                labelStyle: TextStyle(color: Colors.red.shade700),
                side: BorderSide(color: Colors.red.shade300),
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(onTap: onDetails, child: const Text('Ver detalles')),
                PopupMenuItem(
                  onTap: onBlock,
                  child: Text(isBlocked ? 'Reactivar' : 'Desactivar'),
                ),
                PopupMenuItem(
                  onTap: onDelete,
                  child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
        onTap: onDetails,
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
