import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../application/blocs/admin/admin_dashboard_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_state.dart';
import '../../infrastructure/providers/admin_api.dart';
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
  final TextEditingController _searchController = TextEditingController();
  late AdminApi _adminApi;
  List<OwnerData> _owners = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros
  String? _selectedManzana;
  String? _selectedVilla;
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _adminApi = GetIt.I<AdminApi>();
  }

  Future<void> _loadOwners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });
    try {
      final response = await _adminApi.getOwners(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      );
      if (!mounted) return;
      
      // DEBUG: Imprimir respuesta para verificar estructura
      print('=== OWNERS RESPONSE ===');
      setState(() {
        _owners = List<OwnerData>.from(
          response.map((r) {
            if (r is! Map<String, dynamic>) {
              return null;
            }
            
            final nombres = r['nombres'] ?? '';
            final apellidos = r['apellidos'] ?? '';
            final nombreCompleto = '$nombres $apellidos'.trim();
            
            return OwnerData(
              id: r['propietario_id'] ?? 0,
              name: nombreCompleto.isEmpty ? 'N/A' : nombreCompleto,
              manzana: r['manzana'] ?? '',
              villa: r['villa'] ?? '',
              email: r['correo'] ?? '',
              phone: r['celular'] ?? '',
              identificacion: r['identificacion'] ?? '',
              estado: r['estado'] ?? 'activo',
            );
          }).whereType<OwnerData>(),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error al cargar propietarios: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadOwnersByLocation() async {
    if (_selectedManzana == null || _selectedVilla == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona manzana y villa para filtrar')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });
    try {
      final response = await _adminApi.getOwnersByLocation(
        manzana: _selectedManzana!,
        villa: _selectedVilla!,
        page: _currentPage,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      
      // DEBUG: Imprimir respuesta para verificar estructura
      setState(() {
        _owners = List<OwnerData>.from(
          response.map((r) {
            if (r is! Map<String, dynamic>) {
              return null;
            }
            
            final nombres = r['nombres'] ?? '';
            final apellidos = r['apellidos'] ?? '';
            final nombreCompleto = '$nombres $apellidos'.trim();
            
            return OwnerData(
              id: r['propietario_id'] ?? 0,
              name: nombreCompleto.isEmpty ? 'N/A' : nombreCompleto,
              manzana: r['manzana'] ?? '',
              villa: r['villa'] ?? '',
              email: r['correo'] ?? '',
              phone: r['celular'] ?? '',
              identificacion: r['identificacion'] ?? '',
              estado: r['estado'] ?? 'activo',
            );
          }).whereType<OwnerData>(),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error al cargar propietarios: $e');
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

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Gestión de Propietarios',
      routeName: '/adminOwners',
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
                    // Filtros por ubicación
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
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
                            onChanged: (value) {
                              setState(() => _selectedManzana = value.isEmpty ? null : value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
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
                            onChanged: (value) {
                              setState(() => _selectedVilla = value.isEmpty ? null : value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: _loadOwnersByLocation,
                            child: const Text('Buscar Propietarios'),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedManzana = null;
                              _selectedVilla = null;
                              _owners = [];
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
                            'Cargando propietarios...',
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
                                onPressed: _loadOwners,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                        : _owners.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.business,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No se encontraron propietarios',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _owners.length,
                              itemBuilder: (context, index) {
                                final owner = _owners[index];
                                return _OwnerCard(
                                  owner: owner,
                                  onBlock: () => _showBlockDialog(context, owner),
                                  onDelete: () => _showDeleteDialog(context, owner),
                                  onDetails: () => _showDetailsDialog(context, owner),
                                  onViewProperties: () => _showPropertiesDialog(context, owner),
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

  void _showBlockDialog(BuildContext context, OwnerData owner) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(owner.isBlocked ? 'Reactivar propietario' : 'Dar de baja propietario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Propietario: ${owner.name}'),
              const SizedBox(height: 16),
              const Text('Motivo (obligatorio):'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: owner.isBlocked ? 'Motivo de reactivación' : 'Motivo de baja',
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
                if (owner.isBlocked) {
                  // Para reactivar propietario, necesitaríamos un endpoint específico
                  // Por ahora usamos deactivate/activate similar a residentes
                  await _adminApi.reactivateResident(owner.id, reason);
                } else {
                  await _adminApi.deactivateOwner(owner.id, reason);
                }
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      owner.isBlocked
                          ? '${owner.name} ha sido reactivado'
                          : '${owner.name} ha sido dado de baja',
                    ),
                  ),
                );
                _loadOwnersByLocation();
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(owner.isBlocked ? 'Reactivar' : 'Dar de baja'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, OwnerData owner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar propietario'),
        content: Text(
          '¿Desea eliminar la cuenta de ${owner.name}? Esta acción no se puede deshacer.',
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
                await _adminApi.deleteAccount(owner.id);
                if (!mounted) return;
                setState(() => _owners.remove(owner));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${owner.name} ha sido eliminado')),
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

  void _showDetailsDialog(BuildContext context, OwnerData owner) {
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
                    backgroundColor: Colors.purple.shade200,
                    child: Icon(Icons.business_center, size: 32, color: Colors.purple.shade700),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        owner.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${owner.manzana} - ${owner.villa}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailItem(label: 'Identificación', value: owner.identificacion),
              _DetailItem(label: 'Email', value: owner.email),
              _DetailItem(label: 'Teléfono', value: owner.phone),
              _DetailItem(label: 'Ubicación', value: '${owner.manzana} - ${owner.villa}'),
              _DetailItem(
                label: 'Estado',
                value: owner.estado.replaceFirst(owner.estado[0], owner.estado[0].toUpperCase()),
                valueColor: owner.isBlocked ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBlockDialog(context, owner);
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
                        _showDeleteDialog(context, owner);
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

  void _showPropertiesDialog(BuildContext context, OwnerData owner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Propiedades de ${owner.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _PropertyCard(
                      name: 'Manzana A - Villa 101',
                      status: 'Activa',
                      residents: 2,
                    ),
                    _PropertyCard(
                      name: 'Manzana B - Villa 210',
                      status: 'Activa',
                      residents: 1,
                    ),
                    _PropertyCard(
                      name: 'Manzana C - Villa 305',
                      status: 'Alquilada',
                      residents: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final OwnerData owner;
  final VoidCallback onBlock;
  final VoidCallback onDelete;
  final VoidCallback onDetails;
  final VoidCallback onViewProperties;

  const _OwnerCard({
    required this.owner,
    required this.onBlock,
    required this.onDelete,
    required this.onDetails,
    required this.onViewProperties,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: owner.isBlocked ? Colors.red.shade200 : Colors.purple.shade200,
          child: Icon(
            Icons.business_center,
            color: owner.isBlocked ? Colors.red : Colors.purple,
          ),
        ),
        title: Text(owner.name),
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
                PopupMenuItem(onTap: onDetails, child: const Text('Ver detalles')),
                PopupMenuItem(onTap: onViewProperties, child: const Text('Ver propiedades')),
                PopupMenuItem(onTap: onBlock, child: Text(owner.isBlocked ? 'Desbloquear' : 'Bloquear')),
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

class _PropertyCard extends StatelessWidget {
  final String name;
  final String status;
  final int residents;

  const _PropertyCard({
    required this.name,
    required this.status,
    required this.residents,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.home, color: Colors.blue.shade300),
        title: Text(name),
        subtitle: Text('$residents residente${residents != 1 ? 's' : ''} • $status'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class OwnerData {
  final int id;
  final String name;
  final String manzana;
  final String villa;
  final String email;
  final String phone;
  final String identificacion;
  final String estado;

  OwnerData({
    required this.id,
    required this.name,
    required this.manzana,
    required this.villa,
    required this.email,
    required this.phone,
    required this.identificacion,
    required this.estado,
  });

  bool get isBlocked => estado != 'activo';
}
