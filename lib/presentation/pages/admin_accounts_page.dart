import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/admin_account/admin_account_bloc.dart';
import '../../application/blocs/admin_account/admin_account_event.dart';
import '../../application/blocs/admin_account/admin_account_state.dart';
import '../widgets/admin_scaffold.dart';
import '../theme/theme_controller.dart';

class AdminAccountsPage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminAccountsPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminAccountsPage> createState() => _AdminAccountsPageState();
}

class _AdminAccountsPageState extends State<AdminAccountsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _manzanaController = TextEditingController();
  final TextEditingController _villaController = TextEditingController();

  // Para auto-refresh
  String? _lastEmail;
  String? _lastManzana;
  String? _lastVilla;

  @override
  void dispose() {
    _emailController.dispose();
    _manzanaController.dispose();
    _villaController.dispose();
    super.dispose();
  }

  void _handleSearchByEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese un correo')),
      );
      return;
    }

    _lastEmail = email;
    _lastManzana = null;
    _lastVilla = null;

    context.read<AdminAccountBloc>().add(SearchAccountByEmailEvent(email: email));
  }

  void _handleSearchByLocation() {
    final manzana = _manzanaController.text.trim();
    final villa = _villaController.text.trim();

    if (manzana.isEmpty || villa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa manzana y villa')),
      );
      return;
    }

    _lastEmail = null;
    _lastManzana = manzana;
    _lastVilla = villa;

    context.read<AdminAccountBloc>().add(SearchAccountByLocationEvent(
      manzana: manzana,
      villa: villa,
    ));
  }

  void _clearFilters() {
    _emailController.clear();
    _manzanaController.clear();
    _villaController.clear();
    _lastEmail = null;
    _lastManzana = null;
    _lastVilla = null;
  }

  void _reloadLastSearch() {
    if (_lastEmail != null) {
      context.read<AdminAccountBloc>().add(SearchAccountByEmailEvent(email: _lastEmail!));
    } else if (_lastManzana != null && _lastVilla != null) {
      context.read<AdminAccountBloc>().add(SearchAccountByLocationEvent(
        manzana: _lastManzana!,
        villa: _lastVilla!,
      ));
    }
  }

  void _showBlockDialog(Map<String, dynamic> account, String accountName, bool isBlocked) {
    final TextEditingController reasonController = TextEditingController();
    final accountId = account['persona_id'] ?? account['usuario_id'] ?? 0;
    final accountType = account['tipo'] ?? 'N/A';
    bool cascada = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isBlocked ? 'Desbloquear cuenta' : 'Bloquear cuenta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cuenta: $accountName'),
                const SizedBox(height: 16),
                const Text('Motivo (obligatorio):'),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: isBlocked ? 'Motivo de desbloqueo' : 'Motivo de bloqueo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                if (accountType.toLowerCase().contains('residente')) ...[
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Aplicar a cuentas relacionadas'),
                    subtitle: const Text('Familia/dependientes'),
                    value: cascada,
                    onChanged: (value) {
                      setState(() => cascada = value ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
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
                  context.read<AdminAccountBloc>().add(UnblockAccountEvent(
                    accountId: accountId,
                    reason: reason,
                    cascada: cascada,
                  ));
                } else {
                  context.read<AdminAccountBloc>().add(BlockAccountEvent(
                    accountId: accountId,
                    reason: reason,
                    cascada: cascada,
                  ));
                }
              },
              child: Text(isBlocked ? 'Desbloquear' : 'Bloquear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> account, String accountName) {
    final accountId = account['persona_id'] ?? account['usuario_id'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: Text(
          '¿Desea eliminar la cuenta de $accountName? Esta acción no se puede deshacer.',
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
              context.read<AdminAccountBloc>().add(DeleteAccountEvent(accountId: accountId));
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> account) {
    final nombres = account['nombres'] ?? '';
    final apellidos = account['apellidos'] ?? '';
    final accountName = '$nombres $apellidos'.trim();
    final correo = account['correo'] ?? 'N/A';
    final celular = account['celular'] ?? 'N/A';
    final identificacion = account['identificacion'] ?? 'N/A';
    final tipo = account['tipo'] ?? 'N/A';
    final estado = account['estado'] ?? 'activo';
    final manzana = account['manzana'] ?? '-';
    final villa = account['villa'] ?? '-';
    final parentesco = account['parentesco'] ?? '';
    
    bool isBlocked = estado.toLowerCase() == 'inactivo';

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accountName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          parentesco.isNotEmpty ? '$tipo • $parentesco' : tipo,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailItem(label: 'Identificación', value: identificacion),
              _DetailItem(label: 'Email', value: correo),
              _DetailItem(label: 'Teléfono', value: celular),
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
                        _showBlockDialog(account, accountName, isBlocked);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          isBlocked ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Text(isBlocked ? 'Desbloquear' : 'Desactivar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteDialog(account, accountName);
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

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Gestión de Cuentas',
      routeName: '/adminAccounts',
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
        IconButton(
          onPressed: () => ThemeController.toggle(),
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
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
      body: BlocListener<AdminAccountBloc, AdminAccountState>(
        listener: (context, state) {
          if (state is AccountBlocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            _reloadLastSearch();
          } else if (state is AccountUnblocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _reloadLastSearch();
          } else if (state is AccountDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            _reloadLastSearch();
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Búsqueda por correo
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por correo...',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _handleSearchByEmail,
                          child: const Text('Buscar por Correo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  // Filtros por ubicación
                  const Text('O buscar por ubicación:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _handleSearchByLocation,
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
              child: BlocBuilder<AdminAccountBloc, AdminAccountState>(
                builder: (context, state) {
                  if (state is AdminAccountLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Cargando cuentas...'),
                        ],
                      ),
                    );
                  }

                  if (state is AdminAccountError) {
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
                            onPressed: _reloadLastSearch,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AdminAccountInitial) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Busca cuentas por correo o ubicación'),
                        ],
                      ),
                    );
                  }

                  if (state is AccountsSearched && state.accounts.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No se encontraron cuentas'),
                        ],
                      ),
                    );
                  }

                  final accounts = (state is AccountsSearched ? state.accounts : <Map<String, dynamic>>[]);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final nombres = account['nombres'] ?? '';
                      final apellidos = account['apellidos'] ?? '';
                      final accountName = '$nombres $apellidos'.trim();
                      final estado = account['estado'] ?? 'activo';
                      final isBlocked = estado.toLowerCase() == 'inactivo';
                      
                      return _AccountCard(
                        account: account,
                        onBlock: () => _showBlockDialog(account, accountName, isBlocked),
                        onDelete: () => _showDeleteDialog(account, accountName),
                        onDetails: () => _showDetailsDialog(account),
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

class _AccountCard extends StatelessWidget {
  final Map<String, dynamic> account;
  final VoidCallback onBlock;
  final VoidCallback onDelete;
  final VoidCallback onDetails;

  const _AccountCard({
    required this.account,
    required this.onBlock,
    required this.onDelete,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final nombres = account['nombres'] ?? '';
    final apellidos = account['apellidos'] ?? '';
    final nombreCompleto = '$nombres $apellidos'.trim();
    final correo = account['correo'] ?? 'N/A';
    final tipo = account['tipo'] ?? 'N/A';
    final estado = account['estado'] ?? 'activo';
    final isBlocked = estado.toLowerCase() == 'inactivo';
    final parentesco = account['parentesco'] ?? '';

    // Subtitle: tipo • correo (o tipo • parentesco • correo si aplica)
    final subtitle = parentesco.isNotEmpty 
        ? '$tipo • $parentesco • $correo'
        : '$tipo • $correo';

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
        subtitle: Text(subtitle),
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
                  child: Text(isBlocked ? 'Desbloquear' : 'Bloquear'),
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
