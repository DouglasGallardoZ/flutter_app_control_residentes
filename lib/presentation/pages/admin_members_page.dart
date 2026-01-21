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
  final TextEditingController _searchController = TextEditingController();
  late AdminApi _adminApi;
  List<MemberData> _members = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _adminApi = GetIt.I<AdminApi>();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _adminApi.getFamilyMembers();
      if (!mounted) return;
      
      setState(() {
        _members = List<MemberData>.from(
          response.map((r) => MemberData(
            id: r['id'] ?? 0,
            name: r['nombre_completo'] ?? 'N/A',
            relationship: r['relacion'] ?? '',
            parentName: r['nombre_padre_madre'] ?? '',
            section: r['seccion'] ?? '',
            villa: r['villa'] ?? '',
            email: r['email'] ?? '',
            joinDate: r['fecha_registro'] ?? '',
            isBlocked: r['cuenta_bloqueada'] ?? false,
          )),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<MemberData> _mockMembers = [
    MemberData(
      id: 1,
      name: 'Ana Pérez García',
      relationship: 'Hija',
      parentName: 'María Rodríguez',
      section: 'Manzana A',
      villa: 'Villa 101',
      email: 'ana@example.com',
      joinDate: '2023-06-15',
      isBlocked: false,
    ),
    MemberData(
      id: 2,
      name: 'Pedro Rodríguez',
      relationship: 'Padre',
      parentName: 'María Rodríguez',
      section: 'Manzana A',
      villa: 'Villa 101',
      email: 'pedro@example.com',
      joinDate: '2023-07-01',
      isBlocked: false,
    ),
    MemberData(
      id: 3,
      name: 'Carlos Pérez García',
      relationship: 'Hermano',
      parentName: 'María Rodríguez',
      section: 'Manzana A',
      villa: 'Villa 101',
      email: 'carlos.p@example.com',
      joinDate: '2023-08-10',
      isBlocked: true,
    ),
    MemberData(
      id: 4,
      name: 'María López Martínez',
      relationship: 'Madre',
      parentName: 'Juan Pérez',
      section: 'Manzana B',
      villa: 'Villa 205',
      email: 'maria.l@example.com',
      joinDate: '2023-09-20',
      isBlocked: false,
    ),
  ];

  List<MemberData> get filteredMembers {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _members;
    return _members.where((m) => m.name.toLowerCase().contains(query) || m.parentName.toLowerCase().contains(query)).toList();
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar miembro...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
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
                        : filteredMembers.isEmpty
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
                              itemCount: filteredMembers.length,
                              itemBuilder: (context, index) {
                                final member = filteredMembers[index];
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.isBlocked ? 'Desbloquear miembro' : 'Bloquear miembro'),
        content: Text(
          member.isBlocked
              ? '¿Desea desbloquear a ${member.name}? Podrá acceder nuevamente.'
              : '¿Desea bloquear a ${member.name}? No podrá acceder al sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                if (member.isBlocked) {
                  await _adminApi.unblockAccount(member.id);
                } else {
                  await _adminApi.blockAccount(member.id, 'Bloqueado por administrador');
                }
                if (!mounted) return;
                setState(() => member.isBlocked = !member.isBlocked);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      member.isBlocked
                          ? '${member.name} ha sido bloqueado'
                          : '${member.name} ha sido desbloqueado',
                    ),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(member.isBlocked ? 'Desbloquear' : 'Bloquear'),
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
                  Column(
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
                ],
              ),
              const SizedBox(height: 24),
              _DetailItem(label: 'Email', value: member.email),
              _DetailItem(label: 'Relación', value: member.relationship),
              _DetailItem(label: 'Familia principal', value: member.parentName),
              _DetailItem(label: 'Ubicación', value: '${member.section} - ${member.villa}'),
              _DetailItem(label: 'Fecha de registro', value: member.joinDate),
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
        subtitle: Text('${member.relationship} de ${member.parentName} • ${member.section} - ${member.villa}'),
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
  final String parentName;
  final String section;
  final String villa;
  final String email;
  final String joinDate;
  bool isBlocked;

  MemberData({
    required this.id,
    required this.name,
    required this.relationship,
    required this.parentName,
    required this.section,
    required this.villa,
    required this.email,
    required this.joinDate,
    required this.isBlocked,
  });
}
