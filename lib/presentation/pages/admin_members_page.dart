import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../application/blocs/admin/admin_dashboard_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_state.dart';
import '../../infrastructure/providers/admin_api.dart';
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
  late AdminApi _adminApi;
  List<MemberData> _members = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _adminApi = GetIt.I<AdminApi>();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });
    try {
      final manzana = _manzanaController.text.trim();
      final villa = _villaController.text.trim();
      
      if (manzana.isNotEmpty && villa.isNotEmpty) {
        final response = await _adminApi.getFamilyMembersByLocation(
          manzana: manzana,
          villa: villa,
          page: _currentPage,
          pageSize: _pageSize,
        );
        if (!mounted) return;
        
        setState(() {
          _members = List<MemberData>.from(
            response.map((r) {
              if (r is! Map<String, dynamic>) return null;
              return MemberData(
                id: r['miembro_id'] ?? 0,
                name: '${r['nombres'] ?? ''} ${r['apellidos'] ?? ''}'.trim(),
                relationship: r['parentesco'] ?? '',
                manzana: r['manzana'] ?? '',
                villa: r['villa'] ?? '',
                email: r['correo'] ?? '',
                phone: r['celular'] ?? '',
                identificacion: r['identificacion'] ?? '',
                estado: r['estado'] ?? 'activo',
              );
            }).whereType<MemberData>(),
          );
        });
      } else {
        setState(() {
          _members = [];
          _errorMessage = 'Por favor ingrese manzana y villa';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error al cargar miembros: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMembersByVivienda(int viviendaId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });
    try {
      final response = await _adminApi.getFamilyMembersByVivienda(
        viviendaId: viviendaId,
        page: _currentPage,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      
      setState(() {
        _members = List<MemberData>.from(
          response.map((r) {
            if (r is! Map<String, dynamic>) return null;
            return MemberData(
              id: r['miembro_id'] ?? 0,
              name: '${r['nombres'] ?? ''} ${r['apellidos'] ?? ''}'.trim(),
              relationship: r['parentesco'] ?? '',
              manzana: r['manzana'] ?? '',
              villa: r['villa'] ?? '',
              email: r['correo'] ?? '',
              phone: r['celular'] ?? '',
              identificacion: r['identificacion'] ?? '',
              estado: r['estado'] ?? 'activo',
            );
          }).whereType<MemberData>(),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error al cargar miembros: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentPage = 1;
    });
  }

  @override
  void dispose() {
    _manzanaController.dispose();
    _villaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Gestión de Miembros',
      routeName: '/adminMembers',
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
      body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Filtros por manzana y villa
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _manzanaController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Manzana',
                              prefixIcon: const Icon(Icons.home),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _villaController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Villa',
                              prefixIcon: const Icon(Icons.apartment),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: _loadMembers,
                            child: const Text('Buscar Miembros'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _manzanaController.clear();
                            _villaController.clear();
                            setState(() {
                              _members = [];
                              _errorMessage = null;
                            });
                          },
                          icon: const Icon(Icons.clear),
                          tooltip: 'Limpiar filtros',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Cargando miembros...',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                    : _errorMessage != null
                        ? Center(
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
                                _errorMessage!,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              FilledButton.tonal(
                                onPressed: _loadMembers,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                        : _members.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron miembros',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _members.length,
                              itemBuilder: (context, index) {
                                final member = _members[index];
                                return _MemberCard(
                                  member: member,
                                  onBlock: () => _showBlockDialog(context, member),
                                  onDelete: () => _showDeleteDialog(context, member),
                                  onDetails: () => _showDetailsDialog(context, member),
                                );
                              },
                            ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBlockDialog(BuildContext context, MemberData member) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.isBlocked ? 'Reactivar miembro' : 'Desactivar miembro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Miembro: ${member.name}'),
              const SizedBox(height: 16),
              const Text('Motivo (obligatorio):'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: member.isBlocked ? 'Motivo de reactivación' : 'Motivo de desactivación',
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
              try {
                if (member.isBlocked) {
                  await _adminApi.reactivateMember(member.id, reason);
                } else {
                  await _adminApi.deactivateMember(member.id, reason);
                }
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      member.isBlocked
                          ? '${member.name} ha sido reactivado'
                          : '${member.name} ha sido desactivado',
                    ),
                  ),
                );
                _loadMembers();
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(member.isBlocked ? 'Reactivar' : 'Desactivar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, MemberData member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text(
          '¿Desea eliminar la cuenta de ${member.name}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () async {
              try {
                await _adminApi.deleteAccount(member.id);
                if (!mounted) return;
                setState(() => _members.remove(member));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${member.name} ha sido eliminado')),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, MemberData member) {
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
                    backgroundColor: Colors.pink.shade200,
                    child: Icon(Icons.person, size: 32, color: Colors.pink.shade700),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          member.relationship,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailItem(label: 'Email', value: member.email),
              _DetailItem(label: 'Relación', value: member.relationship),
              _DetailItem(label: 'Identificación', value: member.identificacion),
              _DetailItem(label: 'Teléfono', value: member.phone),
              _DetailItem(label: 'Ubicación', value: '${member.manzana} - ${member.villa}'),
              _DetailItem(
                label: 'Estado',
                value: member.isBlocked ? 'Bloqueado' : 'Activo',
                valueColor: member.isBlocked ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBlockDialog(context, member);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          member.isBlocked ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Text(member.isBlocked ? 'Desbloquear' : 'Bloquear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteDialog(context, member);
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
}

class _MemberCard extends StatelessWidget {
  final MemberData member;
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.isBlocked ? Colors.red.shade200 : Colors.pink.shade200,
          child: Icon(
            Icons.person,
            color: member.isBlocked ? Colors.red : Colors.pink,
          ),
        ),
        title: Text(member.name),
        subtitle: Text('${member.relationship} • ${member.manzana} - ${member.villa}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (member.isBlocked)
              Chip(
                label: const Text('Bloqueado', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.red.shade100,
                labelStyle: TextStyle(color: Colors.red.shade700),
                side: BorderSide(color: Colors.red.shade300),
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(onTap: onDetails, child: const Text('Ver detalles')),
                PopupMenuItem(onTap: onBlock, child: Text(member.isBlocked ? 'Desbloquear' : 'Bloquear')),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class MemberData {
  final int id;
  final String name;
  final String relationship;
  final String manzana;
  final String villa;
  final String email;
  final String phone;
  final String identificacion;
  final String estado;

  MemberData({
    required this.id,
    required this.name,
    required this.relationship,
    required this.manzana,
    required this.villa,
    required this.email,
    required this.phone,
    required this.identificacion,
    required this.estado,
  });

  bool get isBlocked => estado != 'activo';
}
