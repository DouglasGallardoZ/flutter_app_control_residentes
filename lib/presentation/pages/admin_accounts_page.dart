import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../application/blocs/admin/admin_dashboard_bloc.dart';
import '../../application/blocs/admin/admin_dashboard_state.dart';
import '../../infrastructure/providers/admin_api.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _manzanaController = TextEditingController();
  final TextEditingController _villaController = TextEditingController();
  late AdminApi _adminApi;
  List<AccountData> _accounts = [];
  List<AccountData> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _adminApi = GetIt.I<AdminApi>();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      // _currentPage = 1;
    });
    try {
      // TODO: Implement getAccounts() in AdminApi
      // For now, using mock data - replace with real API call
      setState(() {
        _accounts = _mockAccounts;
        _searchResults = [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Error al cargar cuentas: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchByEmail(String email) async {
    if (email.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });
    try {
      final response = await _adminApi.getUserByEmail(correo: email);
      if (!mounted) return;
      
      // Construir nombre completo a partir de nombres y apellidos si es necesario
      String fullName = response['nombre_completo'] ?? 
                       response['nombre'] ?? 
                       '${response['nombres'] ?? ''} ${response['apellidos'] ?? ''}'.trim() ?? 
                       'N/A';
      
      // Mapear el estado correctamente
      bool isBlocked = false;
      if (response.containsKey('cuenta_bloqueada')) {
        final val = response['cuenta_bloqueada'];
        isBlocked = val is bool ? val : (val.toString().toLowerCase() == 'true' || val.toString().toLowerCase() == 'inactivo');
      } else if (response.containsKey('estado')) {
        isBlocked = response['estado'].toString().toLowerCase() != 'activo';
      } else if (response.containsKey('bloqueada')) {
        final val = response['bloqueada'];
        isBlocked = val is bool ? val : (val.toString().toLowerCase() == 'true');
      }
      
      // Obtener tipo de usuario
      String type = response['tipo_usuario'] ?? response['tipo'] ?? response['tipo_persona'] ?? 'N/A';
      
      setState(() {
        _searchResults = [
          AccountData(
            id: response['id'] ?? response['persona_id'] ?? response['cuenta_id'] ?? 0,
            firebaseUid: response['firebase_uid'] ?? response['uid'] ?? '',
            name: fullName,
            email: response['email'] ?? response['correo'] ?? '',
            type: type,
            createdDate: response['fecha_registro'] ?? response['fecha_creacion'] ?? '',
            lastLogin: response['ultimo_login'] ?? response['last_login'] ?? 'N/A',
            isBlocked: isBlocked,
            loginAttempts: response['intentos_fallidos'] ?? response['login_attempts'] ?? 0,
            emailVerified: response['correo_verificado'] ?? response['email_verified'] ?? false,
          ),
        ];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _errorMessage = 'No se encontró cuenta con ese correo: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _searchByLocation(String manzana, String villa) async {
    if (manzana.trim().isEmpty || villa.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = 'Por favor ingrese manzana y villa';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });
    try {
      final response = await _adminApi.getUsersByVivienda(
        manzana: manzana.trim(),
        villa: villa.trim(),
      );
      if (!mounted) return;
      
      setState(() {
        _searchResults = List<AccountData>.from(
          response.map((r) {
            if (r is! Map<String, dynamic>) return null;
            
            // Construir nombre completo a partir de múltiples fuentes posibles
            String fullName = r['nombre_completo'] ?? 
                             r['nombre'] ?? 
                             '${r['nombres'] ?? ''} ${r['apellidos'] ?? ''}'.trim() ?? 
                             'N/A';
            
            // Mapear el estado correctamente
            bool isBlocked = false;
            if (r.containsKey('cuenta_bloqueada')) {
              final val = r['cuenta_bloqueada'];
              isBlocked = val is bool ? val : (val.toString().toLowerCase() == 'true' || val.toString().toLowerCase() == 'inactivo');
            } else if (r.containsKey('estado')) {
              isBlocked = r['estado'].toString().toLowerCase() != 'activo';
            } else if (r.containsKey('bloqueada')) {
              final val = r['bloqueada'];
              isBlocked = val is bool ? val : (val.toString().toLowerCase() == 'true');
            }
            
            // Obtener tipo de usuario
            String type = r['tipo_usuario'] ?? r['tipo'] ?? r['tipo_persona'] ?? 'N/A';
            
            return AccountData(
              id: r['id'] ?? r['persona_id'] ?? r['cuenta_id'] ?? 0,
              firebaseUid: r['firebase_uid'] ?? r['uid'] ?? '',
              name: fullName,
              email: r['email'] ?? r['correo'] ?? '',
              type: type,
              createdDate: r['fecha_registro'] ?? r['fecha_creacion'] ?? '',
              lastLogin: r['ultimo_login'] ?? r['last_login'] ?? 'N/A',
              isBlocked: isBlocked,
              loginAttempts: r['intentos_fallidos'] ?? r['login_attempts'] ?? 0,
              emailVerified: r['correo_verificado'] ?? r['email_verified'] ?? false,
            );
          }).whereType<AccountData>(),
        );
        
        if (_searchResults.isEmpty) {
          _errorMessage = 'No se encontraron usuarios en $manzana-$villa';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _errorMessage = 'Error al buscar usuarios: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _manzanaController.dispose();
    _villaController.dispose();
    super.dispose();
  }

  final List<AccountData> _mockAccounts = [
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
                    // Búsqueda por correo
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por correo...',
                        prefixIcon: const Icon(Icons.email),
                        suffixIcon:
                            _emailController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _emailController.clear();
                                    setState(() {
                                      _searchResults = [];
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {
                              if (_emailController.text.isNotEmpty) {
                                _searchByEmail(_emailController.text);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Por favor ingrese un correo')),
                                );
                              }
                            },
                            child: const Text('Buscar por Correo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Separador visual
                    Divider(height: 1, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    // Filtros por manzana y villa
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
                            onPressed: () {
                              if (_manzanaController.text.isNotEmpty && _villaController.text.isNotEmpty) {
                                _searchByLocation(_manzanaController.text, _villaController.text);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Por favor ingrese manzana y villa')),
                                );
                              }
                            },
                            child: const Text('Buscar por Ubicación'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _emailController.clear();
                            _manzanaController.clear();
                            _villaController.clear();
                            setState(() {
                              _searchResults = [];
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
                            'Cargando cuentas...',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                    : _errorMessage != null && _searchResults.isEmpty
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
                                onPressed: _loadAccounts,
                                child: const Text('Ver Todas las Cuentas'),
                              ),
                            ],
                          ),
                        )
                        : _searchResults.isEmpty && _accounts.isEmpty
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
                              itemCount: _searchResults.isNotEmpty ? _searchResults.length : _accounts.length,
                              itemBuilder: (context, index) {
                                final account = _searchResults.isNotEmpty
                                    ? _searchResults[index]
                                    : _accounts[index];
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
    final TextEditingController reasonController = TextEditingController();
    bool cascada = false; // Valor por defecto: desmarcado
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(account.isBlocked ? 'Desbloquear cuenta' : 'Bloquear cuenta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cuenta: ${account.name}'),
                const SizedBox(height: 16),
                const Text('Motivo (obligatorio):'),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: account.isBlocked ? 'Motivo de desbloqueo' : 'Motivo de bloqueo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                // Mostrar opción de cascada si es residente
                if (account.type.toLowerCase().contains('residente')) ...[
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Aplicar a cuentas relacionadas'),
                    subtitle: const Text('Familia/dependientes'),
                    value: cascada,
                    onChanged: (value) {
                      setState(() {
                        cascada = value ?? false;
                      });
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
                  if (account.isBlocked) {
                    await _adminApi.unblockAccount(
                      account.id,
                      reason: reason,
                      cascada: account.type.toLowerCase().contains('residente') ? cascada : false,
                    );
                  } else {
                    await _adminApi.blockAccount(
                      account.id,
                      reason,
                      cascada: account.type.toLowerCase().contains('residente') ? cascada : false,
                    );
                  }
                  if (!mounted) return;
                  setState(() {
                    account.isBlocked = !account.isBlocked;
                    if (!account.isBlocked) account.loginAttempts = 0;
                  });
                  Navigator.pop(context);
                  
                  String statusMsg = account.isBlocked
                      ? '${account.name} ha sido bloqueado'
                      : '${account.name} ha sido desbloqueado';
                  
                  if (account.type.toLowerCase().contains('residente') && cascada) {
                    statusMsg += ' (familia incluida)';
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(statusMsg)),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text(account.isBlocked ? 'Desbloquear' : 'Bloquear'),
            ),
          ],
        ),
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
            onPressed: () async {
              try {
                await _adminApi.deleteAccount(account.id);
                if (!mounted) return;
                setState(() => _accounts.remove(account));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${account.name} ha sido eliminado')),
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
              if (account.createdDate.isNotEmpty)
                _DetailItem(label: 'Creada', value: account.createdDate),
              if (account.lastLogin.isNotEmpty && account.lastLogin != 'N/A')
                _DetailItem(label: 'Último acceso', value: account.lastLogin),
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
