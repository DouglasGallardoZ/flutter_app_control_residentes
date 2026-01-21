import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_state.dart';
import '../widgets/admin_scaffold.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'Todos'; // Todos, Activo, Bloqueado
  final List<AccountData> _accounts = [
    AccountData(
      id: 1,
      firebaseUid: 'uid_001',
      name: 'María Rodríguez',
      email: 'maria@example.com',
      type: 'Residente',
      createdDate: '2023-05-15',
      lastLogin: '2024-01-20',
      isBlocked: false,
      loginAttempts: 0,
      emailVerified: true,
    ),
    AccountData(
      id: 2,
      firebaseUid: 'uid_002',
      name: 'Juan Pérez',
      email: 'juan@example.com',
      type: 'Residente',
      createdDate: '2023-06-20',
      lastLogin: '2024-01-19',
      isBlocked: false,
      loginAttempts: 0,
      emailVerified: true,
    ),
    AccountData(
      id: 3,
      firebaseUid: 'uid_003',
      name: 'Carlos López',
      email: 'carlos@example.com',
      type: 'Propietario',
      createdDate: '2022-01-15',
      lastLogin: '2024-01-15',
      isBlocked: true,
      loginAttempts: 5,
      emailVerified: true,
    ),
    AccountData(
      id: 4,
      firebaseUid: 'uid_004',
      name: 'Andrea Martínez',
      email: 'andrea@example.com',
      type: 'Residente',
      createdDate: '2023-07-10',
      lastLogin: '2023-12-01',
      isBlocked: false,
      loginAttempts: 0,
      emailVerified: false,
    ),
    AccountData(
      id: 5,
      firebaseUid: 'uid_005',
      name: 'Sandra García',
      email: 'sandra@example.com',
      type: 'Propietario',
      createdDate: '2022-03-20',
      lastLogin: '2024-01-18',
      isBlocked: false,
      loginAttempts: 0,
      emailVerified: true,
    ),
  ];

  List<AccountData> get filteredAccounts {
    final query = _searchController.text.toLowerCase();
    List<AccountData> result = _accounts;

    // Filtrar por estado
    if (_filterStatus == 'Activo') {
      result = result.where((a) => !a.isBlocked).toList();
    } else if (_filterStatus == 'Bloqueado') {
      result = result.where((a) => a.isBlocked).toList();
    }

    // Filtrar por búsqueda
    if (query.isNotEmpty) {
      result = result
          .where((a) =>
              a.name.toLowerCase().contains(query) ||
              a.email.toLowerCase().contains(query) ||
              a.firebaseUid.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Gestión de Cuentas',
      routeName: '/adminAccounts',
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
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre, email o UID...',
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
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Todos', 'Activo', 'Bloqueado']
                            .map(
                              (status) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(status),
                                  selected: _filterStatus == status,
                                  onSelected: (selected) {
                                    setState(() => _filterStatus = status);
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredAccounts.isEmpty
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
                            'No se encontraron cuentas',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = filteredAccounts[index];
                        return _AccountCard(
                          account: account,
                          onBlock: () => _showBlockDialog(context, account),
                          onDelete: () => _showDeleteDialog(context, account),
                          onDetails: () => _showDetailsDialog(context, account),
                          onResetPassword: () => _showResetPasswordDialog(context, account),
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

  void _showBlockDialog(BuildContext context, AccountData account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(account.isBlocked ? 'Desbloquear cuenta' : 'Bloquear cuenta'),
        content: Text(
          account.isBlocked
              ? '¿Desea desbloquear la cuenta de ${account.name}? Podrá acceder nuevamente.'
              : '¿Desea bloquear la cuenta de ${account.name}? No podrá acceder al sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                account.isBlocked = !account.isBlocked;
                if (!account.isBlocked) account.loginAttempts = 0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    account.isBlocked
                        ? '${account.name} ha sido bloqueado'
                        : '${account.name} ha sido desbloqueado',
                  ),
                ),
              );
            },
            child: Text(account.isBlocked ? 'Desbloquear' : 'Bloquear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AccountData account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: Text(
          '¿Desea eliminar la cuenta de ${account.name}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            onPressed: () {
              setState(() => _accounts.remove(account));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${account.name} ha sido eliminado')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, AccountData account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer contraseña'),
        content: Text(
          '¿Desea enviar un enlace para restablecer la contraseña a ${account.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Enlace de restablecimiento enviado a ${account.email}'),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, AccountData account) {
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
                    backgroundColor: account.isBlocked ? Colors.red.shade200 : Colors.blue.shade200,
                    child: Icon(
                      Icons.account_circle,
                      size: 32,
                      color: account.isBlocked ? Colors.red : Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        account.type,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailItem(label: 'Email', value: account.email),
              _DetailItem(label: 'Tipo de cuenta', value: account.type),
              _DetailItem(label: 'Firebase UID', value: account.firebaseUid),
              _DetailItem(label: 'Creada', value: account.createdDate),
              _DetailItem(label: 'Último acceso', value: account.lastLogin),
              _DetailItem(
                label: 'Email verificado',
                value: account.emailVerified ? 'Sí' : 'No',
                valueColor: account.emailVerified ? Colors.green : Colors.orange,
              ),
              _DetailItem(
                label: 'Intentos de login',
                value: account.loginAttempts.toString(),
                valueColor: account.loginAttempts > 3 ? Colors.orange : null,
              ),
              _DetailItem(
                label: 'Estado',
                value: account.isBlocked ? 'Bloqueado' : 'Activo',
                valueColor: account.isBlocked ? Colors.red : Colors.green,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showResetPasswordDialog(context, account);
                      },
                      child: const Text('Restablecer Contraseña'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showBlockDialog(context, account);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          account.isBlocked ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Text(account.isBlocked ? 'Desbloquear' : 'Bloquear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteDialog(context, account);
                  },
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
                  child: const Text('Eliminar Cuenta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountData account;
  final VoidCallback onBlock;
  final VoidCallback onDelete;
  final VoidCallback onDetails;
  final VoidCallback onResetPassword;

  const _AccountCard({
    required this.account,
    required this.onBlock,
    required this.onDelete,
    required this.onDetails,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = account.isBlocked ? Colors.red : Colors.green;
    final icon = account.type == 'Propietario' ? Icons.business_center : Icons.person;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: account.isBlocked ? Colors.red.shade100 : Colors.blue.shade100,
          child: Icon(icon, color: statusColor),
        ),
        title: Text(account.name),
        subtitle: Text('${account.email} • ${account.type}'),
        trailing: Wrap(
          spacing: 4,
          children: [
            if (account.isBlocked)
              Chip(
                label: const Text('Bloqueado', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.red.shade100,
                labelStyle: TextStyle(color: Colors.red.shade700),
                side: BorderSide(color: Colors.red.shade300),
              )
            else if (!account.emailVerified)
              Chip(
                label: const Text('Email no verificado', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.orange.shade100,
                labelStyle: TextStyle(color: Colors.orange.shade700),
                side: BorderSide(color: Colors.orange.shade300),
              ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(onTap: onDetails, child: const Text('Ver detalles')),
                PopupMenuItem(onTap: onResetPassword, child: const Text('Restablecer contraseña')),
                PopupMenuItem(onTap: onBlock, child: Text(account.isBlocked ? 'Desbloquear' : 'Bloquear')),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountData {
  final int id;
  final String firebaseUid;
  final String name;
  final String email;
  final String type; // Residente, Propietario, Miembro
  final String createdDate;
  final String lastLogin;
  bool isBlocked;
  int loginAttempts;
  final bool emailVerified;

  AccountData({
    required this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.type,
    required this.createdDate,
    required this.lastLogin,
    required this.isBlocked,
    required this.loginAttempts,
    required this.emailVerified,
  });
}
