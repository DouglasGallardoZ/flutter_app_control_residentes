import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../application/blocs/admin/admin_dashboard_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_state.dart';
import '../../infrastructure/providers/admin_api.dart';
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
  State<AdminResidentsPage> createState() => _AdminResidentsPageState();
}

class _AdminResidentsPageState extends State<AdminResidentsPage> {
  final TextEditingController _searchController = TextEditingController();
  late AdminApi _adminApi;
  List<ResidentData> _residents = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _adminApi = GetIt.I<AdminApi>();
    _loadResidents();
  }

  Future<void> _loadResidents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _adminApi.getResidents();
      if (!mounted) return;
      
      setState(() {
        _residents = List<ResidentData>.from(
          response.map((r) => ResidentData(
            id: r['id'] ?? 0,
            name: r['nombre_completo'] ?? 'N/A',
            section: r['seccion'] ?? '',
            villa: r['villa'] ?? '',
            email: r['email'] ?? '',
            phone: r['telefono'] ?? '',
            isBlocked: r['cuenta_bloqueada'] ?? false,
            joinDate: r['fecha_registro'] ?? '',
          )),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error al cargar residentes: $e');
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

  final List<ResidentData> _mockResidents = [
    ResidentData(
      id: 1,
      name: 'María Rodríguez',
      section: 'Manzana A',
      villa: 'Villa 101',
      email: 'maria@example.com',
      phone: '+34 612 345 678',
      isBlocked: false,
      joinDate: '2023-05-15',
    ),
    ResidentData(
      id: 2,
      name: 'Juan Pérez',
      section: 'Manzana B',
      villa: 'Villa 205',
      email: 'juan@example.com',
      phone: '+34 623 456 789',
      isBlocked: false,
      joinDate: '2023-06-20',
    ),
    ResidentData(
      id: 3,
      name: 'Andrea Martínez',
      section: 'Manzana C',
      villa: 'Villa 308',
      email: 'andrea@example.com',
      phone: '+34 634 567 890',
      isBlocked: true,
      joinDate: '2023-07-10',
    ),
  ];

  List<ResidentData> get filteredResidents {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _residents;
    return _residents
        .where((r) => r.name.toLowerCase().contains(query) || r.villa.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Gestión de Residentes',
      routeName: '/adminResidents',
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
                    hintText: 'Buscar residente...',
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
                            'Cargando residentes...',
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
                                onPressed: _loadResidents,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                        : filteredResidents.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron residentes',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredResidents.length,
                              itemBuilder: (context, index) {
                                final resident = filteredResidents[index];
                                return _ResidentCard(
                                  resident: resident,
                                  onBlock: () => _showBlockDialog(context, resident),
                                  onDelete: () => _showDeleteDialog(context, resident),
                                  onDetails: () => _showDetailsDialog(context, resident),
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

  void _showBlockDialog(BuildContext context, ResidentData resident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resident.isBlocked ? 'Desbloquear residente' : 'Bloquear residente'),
        content: Text(
          resident.isBlocked
              ? '¿Desea desbloquear a ${resident.name}? Podrá acceder nuevamente.'
              : '¿Desea bloquear a ${resident.name}? No podrá acceder al sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                if (resident.isBlocked) {
                  await _adminApi.unblockAccount(resident.id);
                } else {
                  await _adminApi.blockAccount(resident.id, 'Bloqueado por administrador');
                }
                if (!mounted) return;
                setState(() => resident.isBlocked = !resident.isBlocked);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      resident.isBlocked
                          ? '${resident.name} ha sido bloqueado'
                          : '${resident.name} ha sido desbloqueado',
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
            child: Text(resident.isBlocked ? 'Desbloquear' : 'Bloquear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ResidentData resident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar residente'),
        content: Text(
          '¿Desea eliminar la cuenta de ${resident.name}? Esta acción no se puede deshacer.',
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
                await _adminApi.deleteAccount(resident.id);
                if (!mounted) return;
                setState(() => _residents.remove(resident));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${resident.name} ha sido eliminado')),
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

  void _showDetailsDialog(BuildContext context, ResidentData resident) {
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
                    backgroundColor: Colors.blue.shade200,
                    child: Icon(Icons.person, size: 32, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resident.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        resident.villa,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailItem(label: 'Email', value: resident.email),
              _DetailItem(label: 'Teléfono', value: resident.phone),
              _DetailItem(label: 'Sección', value: '${resident.section} - ${resident.villa}'),
              _DetailItem(label: 'Fecha de registro', value: resident.joinDate),
              _DetailItem(
                label: 'Estado',
                value: resident.isBlocked ? 'Bloqueado' : 'Activo',
                valueColor: resident.isBlocked ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBlockDialog(context, resident);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          resident.isBlocked ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Text(resident.isBlocked ? 'Desbloquear' : 'Bloquear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteDialog(context, resident);
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

class _ResidentCard extends StatelessWidget {
  final ResidentData resident;
  final VoidCallback onBlock;
  final VoidCallback onDelete;
  final VoidCallback onDetails;

  const _ResidentCard({
    required this.resident,
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
          backgroundColor: resident.isBlocked ? Colors.red.shade200 : Colors.blue.shade200,
          child: Icon(
            Icons.person,
            color: resident.isBlocked ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(resident.name),
        subtitle: Text('${resident.section} - ${resident.villa}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (resident.isBlocked)
              Chip(
                label: const Text('Bloqueado', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.red.shade100,
                labelStyle: TextStyle(color: Colors.red.shade700),
                side: BorderSide(color: Colors.red.shade300),
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(onTap: onDetails, child: const Text('Ver detalles')),
                PopupMenuItem(onTap: onBlock, child: Text(resident.isBlocked ? 'Desbloquear' : 'Bloquear')),
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

class ResidentData {
  final int id;
  final String name;
  final String section;
  final String villa;
  final String email;
  final String phone;
  bool isBlocked;
  final String joinDate;

  ResidentData({
    required this.id,
    required this.name,
    required this.section,
    required this.villa,
    required this.email,
    required this.phone,
    required this.isBlocked,
    required this.joinDate,
  });
}
