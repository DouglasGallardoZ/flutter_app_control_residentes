import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _loadResidents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
    });
    try {
      final response = await _adminApi.getResidents(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      );
      if (!mounted) return;
      
      // DEBUG: Imprimir respuesta para verificar estructura
      print('=== RESIDENTES RESPONSE ===');
      setState(() {
        _residents = List<ResidentData>.from(
          response.map((r) {
            if (r is! Map<String, dynamic>) {
              return null;
            }
            
            final nombres = r['nombres'] ?? '';
            final apellidos = r['apellidos'] ?? '';
            final nombreCompleto = '$nombres $apellidos'.trim();
            
            return ResidentData(
              id: r['residente_id'] ?? 0,
              name: nombreCompleto.isEmpty ? 'N/A' : nombreCompleto,
              manzana: r['manzana'] ?? '',
              villa: r['villa'] ?? '',
              email: r['correo'] ?? '',
              phone: r['celular'] ?? '',
              identificacion: r['identificacion'] ?? '',
              estado: r['estado'] ?? 'activo',
            );
          }).whereType<ResidentData>(),
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

  Future<void> _loadResidentsByLocation() async {
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
      final response = await _adminApi.getResidentsByLocation(
        manzana: _selectedManzana!,
        villa: _selectedVilla!,
        page: _currentPage,
        pageSize: _pageSize,
      );
      if (!mounted) return;
      
      // DEBUG: Imprimir respuesta para verificar estructura
      print('=== RESIDENTES BY LOCATION RESPONSE ===');
      setState(() {
        _residents = List<ResidentData>.from(
          response.map((r) {
            if (r is! Map<String, dynamic>) {
              return null;
            }
            
            final nombres = r['nombres'] ?? '';
            final apellidos = r['apellidos'] ?? '';
            final nombreCompleto = '$nombres $apellidos'.trim();
            
            return ResidentData(
              id: r['residente_id'] ?? 0,
              name: nombreCompleto.isEmpty ? 'N/A' : nombreCompleto,
              manzana: r['manzana'] ?? '',
              villa: r['villa'] ?? '',
              email: r['correo'] ?? '',
              phone: r['celular'] ?? '',
              identificacion: r['identificacion'] ?? '',
              estado: r['estado'] ?? 'activo',
            );
          }).whereType<ResidentData>(),
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
                  '/adminCreateResident',
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
              // Filtros por ubicación
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
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
                            onPressed: _loadResidentsByLocation,
                            child: const Text('Buscar Residentes'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedManzana = null;
                              _selectedVilla = null;
                              _residents = [];
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
              const SizedBox(height: 16),
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
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resident.isBlocked ? 'Reactivar residente' : 'Desactivar residente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Residente: ${resident.name}'),
              const SizedBox(height: 16),
              const Text('Motivo (obligatorio):'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: resident.isBlocked ? 'Motivo de reactivación' : 'Motivo de desactivación',
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
                if (resident.isBlocked) {
                  await _adminApi.reactivateResident(resident.id, reason);
                } else {
                  await _adminApi.deactivateResident(resident.id, reason);
                }
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      resident.isBlocked
                          ? '${resident.name} ha sido reactivado'
                          : '${resident.name} ha sido desactivado',
                    ),
                  ),
                );
                _loadResidentsByLocation();
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(resident.isBlocked ? 'Reactivar' : 'Desactivar'),
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
              _DetailItem(label: 'Identificación', value: resident.identificacion),
              _DetailItem(label: 'Email', value: resident.email),
              _DetailItem(label: 'Teléfono', value: resident.phone),
              _DetailItem(label: 'Ubicación', value: '${resident.manzana} - ${resident.villa}'),
              _DetailItem(
                label: 'Estado',
                value: resident.estado.replaceFirst(resident.estado[0], resident.estado[0].toUpperCase()),
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
        subtitle: Text('${resident.manzana} - ${resident.villa}'),
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
  final String manzana;
  final String villa;
  final String email;
  final String phone;
  final String identificacion;
  final String estado;

  ResidentData({
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
