import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/resident/resident_bloc.dart';
import '../../application/blocs/resident/resident_event.dart';
import '../../application/blocs/resident/resident_state.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/responsive_layout.dart';

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

    context.read<ResidentBloc>().add(LoadResidentsByLocationEvent(
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

  void _reloadResidentsFromLastSearch() {
    if (_lastManzana != null && _lastVilla != null) {
      context.read<ResidentBloc>().add(LoadResidentsByLocationEvent(
        manzana: _lastManzana!,
        villa: _lastVilla!,
      ));
    }
  }

  void _showResidentDetails(Map<String, dynamic> resident) {
    final nombres = resident['nombres'] ?? '';
    final apellidos = resident['apellidos'] ?? '';
    final nombreCompleto = '$nombres $apellidos'.trim();
    final manzana = resident['manzana'] ?? '';
    final villa = resident['villa'] ?? '';
    final estado = resident['estado'] ?? 'activo';
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
                    backgroundColor: isBlocked ? Colors.red.shade200 : Colors.blue.shade200,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: isBlocked ? Colors.red.shade700 : Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreCompleto,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'M$manzana - V$villa',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailItem(label: 'Identificación', value: resident['identificacion'] ?? 'N/A'),
              _DetailItem(label: 'Email', value: resident['correo'] ?? 'N/A'),
              _DetailItem(label: 'Teléfono', value: resident['celular'] ?? 'N/A'),
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
                        _showBlockDialog(resident, nombreCompleto, isBlocked);
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
                        _showDeleteDialog(resident, nombreCompleto);
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

  void _showBlockDialog(Map<String, dynamic> resident, String nombreCompleto, bool isBlocked) {
    final TextEditingController reasonController = TextEditingController();
    final residentId = resident['residente_id'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBlocked ? 'Reactivar residente' : 'Desactivar residente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Residente: $nombreCompleto'),
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
                context.read<ResidentBloc>().add(ReactivateResidentEvent(
                  personaId: residentId,
                  reason: reason,
                ));
              } else {
                context.read<ResidentBloc>().add(DeactivateResidentEvent(
                  personaId: residentId,
                  reason: reason,
                ));
              }
            },
            child: Text(isBlocked ? 'Reactivar' : 'Desactivar'),
          ),
        ],
      ),
    ).then((_) => reasonController.dispose());
  }

  void _showDeleteDialog(Map<String, dynamic> resident, String nombreCompleto) {
    final residentId = resident['residente_id'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar residente'),
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
              context.read<ResidentBloc>().add(DeleteResidentEvent(residentId));
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
            case 4:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/adminNotificaciones', (route) => false,
                  arguments: {
                    'personaId': widget.personaId,
                    'identificacion': widget.identificacion,
                  });
              break;
          }
        });
      },
      body: BlocListener<ResidentBloc, ResidentState>(
        listener: (context, state) {
          if (state is ResidentDeactivated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            _reloadResidentsFromLastSearch();
          } else if (state is ResidentReactivated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _reloadResidentsFromLastSearch();
          } else if (state is ResidentDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            _reloadResidentsFromLastSearch();
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ResponsiveLayout(
                mobile: Column(
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
                            child: const Text('Buscar Residentes'),
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
                tablet: Row(
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
                    const SizedBox(width: 12),
                    FilledButton.tonal(
                      onPressed: _handleFilterByLocation,
                      child: const Text('Buscar'),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpiar filtros',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ResidentBloc, ResidentState>(
                builder: (context, state) {
                  if (state is ResidentLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando residentes...'),
                        ],
                      ),
                    );
                  }

                  if (state is ResidentError) {
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

                  if (state is ResidentInitial) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Busca residentes por manzana y villa'),
                        ],
                      ),
                    );
                  }

                  if (state is ResidentsByLocationLoaded && state.residents.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No se encontraron residentes'),
                        ],
                      ),
                    );
                  }

                  final residents = (state is ResidentsByLocationLoaded ? state.residents : <Map<String, dynamic>>[]);

                  if (ResponsiveLayout.isWide(context)) {
                    return _ResidentsDataTable(
                      residents: residents,
                      onDetails: (r) => _showResidentDetails(r),
                      onBlock: (r) {
                        final nombres = r['nombres'] ?? '';
                        final apellidos = r['apellidos'] ?? '';
                        final nombreCompleto = '$nombres $apellidos'.trim();
                        final estado = r['estado'] ?? 'activo';
                        final isBlocked = estado.toLowerCase() == 'inactivo';
                        _showBlockDialog(r, nombreCompleto, isBlocked);
                      },
                      onDelete: (r) {
                        final nombres = r['nombres'] ?? '';
                        final apellidos = r['apellidos'] ?? '';
                        final nombreCompleto = '$nombres $apellidos'.trim();
                        _showDeleteDialog(r, nombreCompleto);
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: residents.length,
                    itemBuilder: (context, index) {
                      final resident = residents[index];
                      return _ResidentCard(
                        resident: resident,
                        onDetails: () => _showResidentDetails(resident),
                        onBlock: () {
                          final nombres = resident['nombres'] ?? '';
                          final apellidos = resident['apellidos'] ?? '';
                          final nombreCompleto = '$nombres $apellidos'.trim();
                          final estado = resident['estado'] ?? 'activo';
                          final isBlocked = estado.toLowerCase() == 'inactivo';
                          _showBlockDialog(resident, nombreCompleto, isBlocked);
                        },
                        onDelete: () {
                          final nombres = resident['nombres'] ?? '';
                          final apellidos = resident['apellidos'] ?? '';
                          final nombreCompleto = '$nombres $apellidos'.trim();
                          _showDeleteDialog(resident, nombreCompleto);
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

class _ResidentCard extends StatelessWidget {
  final Map<String, dynamic> resident;
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
    final nombres = resident['nombres'] ?? '';
    final apellidos = resident['apellidos'] ?? '';
    final nombreCompleto = '$nombres $apellidos'.trim();
    final manzana = resident['manzana'] ?? '';
    final villa = resident['villa'] ?? '';
    final estado = resident['estado'] ?? 'activo';
    final isBlocked = estado.toLowerCase() == 'inactivo';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBlocked ? Colors.red.shade200 : Colors.blue.shade200,
          child: Icon(
            Icons.person,
            color: isBlocked ? Colors.red : Colors.blue,
          ),
        ),
        title: Text(nombreCompleto),
        subtitle: Text('$manzana - $villa'),
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

class _ResidentsDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> residents;
  final void Function(Map<String, dynamic>) onDetails;
  final void Function(Map<String, dynamic>) onBlock;
  final void Function(Map<String, dynamic>) onDelete;

  const _ResidentsDataTable({
    required this.residents,
    required this.onDetails,
    required this.onBlock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: const Text('Residentes'),
      columns: const [
        DataColumn(label: Text('Nombres')),
        DataColumn(label: Text('Apellidos')),
        DataColumn(label: Text('Identificación')),
        DataColumn(label: Text('Manzana')),
        DataColumn(label: Text('Villa')),
        DataColumn(label: Text('Correo')),
        DataColumn(label: Text('Estado')),
        DataColumn(label: Text('Acciones')),
      ],
      source: _ResidentsDataTableSource(
        residents: residents,
        onDetails: onDetails,
        onBlock: onBlock,
        onDelete: onDelete,
      ),
      rowsPerPage: 10,
      showFirstLastButtons: true,
      showCheckboxColumn: false,
    );
  }
}

class _ResidentsDataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> residents;
  final void Function(Map<String, dynamic>) onDetails;
  final void Function(Map<String, dynamic>) onBlock;
  final void Function(Map<String, dynamic>) onDelete;

  _ResidentsDataTableSource({
    required this.residents,
    required this.onDetails,
    required this.onBlock,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= residents.length) return null;
    final r = residents[index];
    final estado = r['estado'] ?? 'activo';
    final isBlocked = estado.toLowerCase() == 'inactivo';

    return DataRow(
      cells: [
        DataCell(Text(r['nombres'] ?? '')),
        DataCell(Text(r['apellidos'] ?? '')),
        DataCell(Text(r['identificacion'] ?? '')),
        DataCell(Text(r['manzana'] ?? '')),
        DataCell(Text(r['villa'] ?? '')),
        DataCell(Text(r['correo'] ?? '')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isBlocked ? Icons.block : Icons.check_circle,
                size: 16,
                color: isBlocked ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(isBlocked ? 'Inactivo' : 'Activo'),
            ],
          ),
        ),
        DataCell(
          PopupMenuButton<String>(
            onSelected: (action) {
              switch (action) {
                case 'details':
                  onDetails(r);
                  break;
                case 'block':
                  onBlock(r);
                  break;
                case 'delete':
                  onDelete(r);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'details', child: Text('Ver detalles')),
              PopupMenuItem(
                value: 'block',
                child: Text(isBlocked ? 'Reactivar' : 'Desactivar'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => residents.length;

  @override
  int get selectedRowCount => 0;
}
