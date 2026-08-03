import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/admin_account/admin_account_bloc.dart';
import '../../application/blocs/admin_account/admin_account_event.dart';
import '../../application/blocs/admin_account/admin_account_state.dart';
import '../widgets/admin_scaffold.dart';

class AdminAccountsPage
    extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminAccountsPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminAccountsPage>
  createState() =>
      _AdminAccountsPageState();
}

class _AdminAccountsPageState
    extends State<AdminAccountsPage> {
  final _emailCtrl =
      TextEditingController();
  final _manzanaCtrl =
      TextEditingController();
  final _villaCtrl =
      TextEditingController();

  bool _modoEmail = true;
  String? _lastSearchValue;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _manzanaCtrl.dispose();
    _villaCtrl.dispose();
    super.dispose();
  }

  void _buscar() {
    if (_modoEmail) {
      final email =
          _emailCtrl.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
              content: Text(
                  'Ingresa un correo electrónico')),
        );
        return;
      }
      _lastSearchValue = email;
      context
          .read<AdminAccountBloc>()
          .add(SearchAccountByEmailEvent(
              email: email));
    } else {
      final m =
          _manzanaCtrl.text.trim();
      final v =
          _villaCtrl.text.trim();
      if (m.isEmpty || v.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
              content: Text(
                  'Ingresa manzana y villa')),
        );
        return;
      }
      _lastSearchValue =
          '$m:$v';
      context
          .read<AdminAccountBloc>()
          .add(SearchAccountByLocationEvent(
            manzana: m,
            villa: v,
          ));
    }
  }

  void _recargar() {
    if (_lastSearchValue == null) {
      return;
    }
    if (_modoEmail) {
      context
          .read<AdminAccountBloc>()
          .add(SearchAccountByEmailEvent(
              email:
                  _lastSearchValue!));
    } else {
      final parts = _lastSearchValue!
          .split(':');
      if (parts.length == 2) {
        context
            .read<AdminAccountBloc>()
            .add(SearchAccountByLocationEvent(
              manzana: parts[0],
              villa: parts[1],
            ));
      }
    }
  }

  Future<void> _confirmarBloqueo(
    BuildContext context,
    Map<String, dynamic> account,
    bool bloquear,
  ) async {
    final nombre =
        '${account['nombres'] ?? ''} ${account['apellidos'] ?? ''}'
            .trim();
    final motivoCtrl =
        TextEditingController();
    bool cascada = false;

    final confirmado =
        await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          StatefulBuilder(
        builder: (ctx,
                setDialogState) =>
            AlertDialog(
          title: Text(bloquear
              ? 'Bloquear Cuenta'
              : 'Desbloquear Cuenta'),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(bloquear
                  ? '¿Bloquear la cuenta de $nombre?'
                  : '¿Desbloquear la cuenta de $nombre?'),
              const SizedBox(
                  height: 16),
              TextField(
                controller:
                    motivoCtrl,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Motivo *',
                  border:
                      OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (_) =>
                    setDialogState(() {}),
              ),
              const SizedBox(
                  height: 16),
              CheckboxListTile(
                value: cascada,
                onChanged: (v) =>
                    setDialogState(
                        () =>
                            cascada =
                                v ??
                                    false),
                title: Text(bloquear
                    ? 'Bloqueo en cascada'
                    : 'Desbloqueo en cascada'),
                subtitle: Text(
                  bloquear
                      ? 'También bloquea las cuentas de los miembros de familia asociados a esta cuenta'
                      : 'También desbloquea las cuentas de los miembros de familia asociados a esta cuenta',
                  style: TextStyle(
                      fontSize: 12),
                ),
                controlAffinity:
                    ListTileControlAffinity
                        .leading,
                contentPadding:
                    EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                      ctx, false),
              child: const Text(
                  'Cancelar'),
            ),
            FilledButton(
              onPressed: motivoCtrl
                      .text
                      .trim()
                      .isNotEmpty
                  ? () => Navigator.pop(
                      ctx, true)
                  : null,
              style: FilledButton
                  .styleFrom(
                backgroundColor: bloquear
                    ? Colors
                        .orange
                    : Colors
                        .green,
              ),
              child: Text(bloquear
                  ? 'Bloquear'
                  : 'Desbloquear'),
            ),
          ],
        ),
      ),
    );

    final motivo = motivoCtrl.text.trim();

    if (confirmado == true &&
        context.mounted) {
      final accountId =
          account['usuario_id'] ?? 0;
      if (bloquear) {
        context
            .read<AdminAccountBloc>()
            .add(BlockAccountEvent(
          accountId: accountId
                  is int
              ? accountId
              : int.tryParse(accountId
                      .toString()) ??
                  0,
          reason: motivo,
          cascada: cascada,
        ));
      } else {
        context
            .read<AdminAccountBloc>()
            .add(UnblockAccountEvent(
          accountId: accountId
                  is int
              ? accountId
              : int.tryParse(accountId
                      .toString()) ??
                  0,
          reason: motivo,
          cascada: cascada,
        ));
      }
    }
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    Map<String, dynamic> account,
  ) async {
    final nombre =
        '${account['nombres'] ?? ''} ${account['apellidos'] ?? ''}'
            .trim();
    final identificacion =
        account['identificacion']?.toString() ?? '';
    final correo =
        account['correo']?.toString() ?? account['email']?.toString() ?? '';
    final motivoCtrl = TextEditingController();
    var confirmado = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.warning_amber,
                color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Eliminar Cuenta'),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      if (identificacion.isNotEmpty)
                        Text(identificacion,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13)),
                      if (correo.isNotEmpty)
                        Text(correo,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta acción es definitiva e irreversible. '
                        'La cuenta no podrá ser recuperada.',
                        style: TextStyle(
                            color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: motivoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Motivo de eliminación *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (_) =>
                      setDialogState(() {}),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: confirmado,
                  onChanged: (v) {
                    setDialogState(
                        () => confirmado = v ?? false);
                  },
                  title: const Text(
                    'Confirmo que deseo eliminar esta cuenta permanentemente',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity:
                      ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.red,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: (motivoCtrl.text.trim().isNotEmpty &&
                      confirmado)
                  ? () => Navigator.pop(ctx, true)
                  : null,
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.red),
              child: const Text('Eliminar Permanentemente'),
            ),
          ],
        ),
      ),
    );

    final motivo = motivoCtrl.text.trim();

    if (result == true && mounted) {
      final accountId = account['usuario_id'] ?? 0;
      context.read<AdminAccountBloc>().add(DeleteAccountEvent(
            accountId: accountId is int
                ? accountId
                : int.tryParse(accountId.toString()) ?? 0,
            motivo: motivo,
          ));
    }
  }

  Future<void> _resetPassword(
    BuildContext context,
    Map<String, dynamic> account,
  ) async {
    final email =
        account['email']
                ?.toString() ??
            '';
    final passwordCtrl =
        TextEditingController();
    final confirmado =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
            'Restablecer Contraseña'),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
                'Nueva contraseña para $email'),
            const SizedBox(
                height: 16),
            TextField(
              controller:
                  passwordCtrl,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    'Nueva contraseña',
                border:
                    OutlineInputBorder(),
                helperText:
                    'Mínimo 6 caracteres',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    ctx, false),
            child: const Text(
                'Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if ((passwordCtrl.text)
                      .length <
                  6) {
                ScaffoldMessenger.of(
                        ctx)
                    .showSnackBar(
                  const SnackBar(
                      content: Text(
                          'La contraseña debe tener al menos 6 caracteres')),
                );
                return;
              }
              Navigator.pop(
                  ctx, true);
            },
            style: FilledButton
                .styleFrom(
                    backgroundColor:
                        Colors.blue),
            child: const Text(
                'Restablecer'),
          ),
        ],
      ),
    );
    if (confirmado == true &&
        context.mounted) {
      final accountId =
          account['usuario_id'] ?? 0;
      context
          .read<AdminAccountBloc>()
          .add(ResetPasswordEvent(
        accountId: accountId
                is int
            ? accountId
            : int.tryParse(accountId
                    .toString()) ??
                0,
        newPassword:
            passwordCtrl.text,
      ));
    }
    passwordCtrl.dispose();
  }

  Future<void> _verDetalle(
      Map<String, dynamic> account) async {
    final accountBloc =
        context.read<AdminAccountBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(
          value: accountBloc,
          child: BlocListener<
              AdminAccountBloc,
              AdminAccountState>(
            listener: (context,
                state) {
              if (state
                      is AccountBlocked ||
                  state
                      is AccountUnblocked ||
                  state
                      is AccountDeleted) {
                Navigator.of(context)
                    .pop();
              }
            },
            child: _AccountDetailPage(
              account: account,
              onBloquear: () =>
                  _confirmarBloqueo(context,
                      account, true),
              onDesbloquear: () =>
                  _confirmarBloqueo(context,
                      account, false),
              onEliminar: () =>
                  _confirmarEliminar(
                      context, account),
              onResetPassword: () =>
                  _resetPassword(
                      context, account),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminScaffold(
      title: 'Gestión de Cuentas',
      routeName: '/adminAccounts',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.of(context)
              .pushReplacementNamed(
        '/adminUsers',
        arguments: {
          'personaId':
              widget.personaId,
          'identificacion':
              widget.identificacion,
        },
      ),
      onTabSelected: (i) {
        if (i == 1) return;
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          final routes = [
            '/adminDashboard',
            // TODO: Restaurar cuando se implemente el módulo de historial
            // '/adminAccessHistory',
            null,
            '/adminProfile',
            '/adminNotificaciones',
            '/adminViviendas',
          ];
          if (routes[i] != null) {
            Navigator.of(context)
                .pushReplacementNamed(
              routes[i]!,
              arguments: {
                'personaId':
                    widget.personaId,
                'identificacion':
                    widget.identificacion,
              },
            );
          }
        });
      },
      body: BlocListener<AdminAccountBloc,
          AdminAccountState>(
        listener: (context, state) {
          if (state
              is AccountBlocked) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(SnackBar(
              content:
                  Text(state.message),
              backgroundColor:
                  Colors.orange,
            ));
            _recargar();
          } else if (state
              is AccountUnblocked) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(SnackBar(
              content:
                  Text(state.message),
              backgroundColor:
                  Colors.green,
            ));
            _recargar();
          } else if (state
              is AccountDeleted) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(SnackBar(
              content:
                  Text(state.message),
              backgroundColor:
                  Colors.red,
            ));
            _recargar();
          } else if (state
              is PasswordReset) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(SnackBar(
              content:
                  Text(state.message),
              backgroundColor:
                  Colors.blue,
            ));
          }
        },
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                          16,
                          16,
                          16,
                          0),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text(
                          'Buscar por Email'),
                      selected:
                          _modoEmail,
                      onSelected: (_) =>
                          setState(() =>
                              _modoEmail =
                                  true),
                      selectedColor:
                          const Color(
                              0xFF04345C),
                      labelStyle:
                          TextStyle(
                        color:
                            _modoEmail
                                ? Colors
                                    .white
                                : null,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text(
                          'Buscar por Ubicación'),
                      selected:
                          !_modoEmail,
                      onSelected: (_) =>
                          setState(() =>
                              _modoEmail =
                                  false),
                      selectedColor:
                          const Color(
                              0xFF04345C),
                      labelStyle:
                          TextStyle(
                        color: !_modoEmail
                            ? Colors
                                .white
                            : null,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.all(
                      16),
              child: _modoEmail
                  ? _buildEmailSearch()
                  : _buildLocationSearch(),
            ),
            const Divider(
                height: 1),
            Expanded(
              child: BlocBuilder<
                  AdminAccountBloc,
                  AdminAccountState>(
                builder: (context,
                    state) {
                  if (state
                      is AdminAccountLoading) {
                    return const Center(
                        child:
                            CircularProgressIndicator());
                  }

                  if (state
                      is AdminAccountError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons
                                .error_outline,
                            size: 48,
                            color: theme
                                .colorScheme
                                .error,
                          ),
                          const SizedBox(
                              height:
                                  16),
                          Text(
                              state
                                  .message,
                              textAlign:
                                  TextAlign
                                      .center),
                          const SizedBox(
                              height:
                                  16),
                          ElevatedButton
                              .icon(
                            onPressed:
                                _recargar,
                            icon: const Icon(
                                Icons
                                    .refresh),
                            label: const Text(
                                'Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state
                      is AdminAccountInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Colors
                                .grey
                                .shade400,
                          ),
                          const SizedBox(
                              height:
                                  16),
                          Text(
                            _modoEmail
                                ? 'Busca una cuenta por correo electrónico'
                                : 'Busca cuentas por manzana y villa',
                            style: theme
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: Colors
                                        .grey),
                            textAlign:
                                TextAlign
                                    .center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (state
                      is AccountsSearched) {
                    if (state
                        .accounts
                        .isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .account_circle_outlined,
                              size: 64,
                              color: Colors
                                  .grey
                                  .shade400,
                            ),
                            const SizedBox(
                                height:
                                    16),
                            const Text(
                              'No se encontraron cuentas',
                              style: TextStyle(
                                  color: Colors
                                      .grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async =>
                          _recargar(),
                      child: ListView
                          .builder(
                        padding:
                            const EdgeInsets.all(16),
                        itemCount: state
                            .accounts
                            .length,
                        itemBuilder: (context,
                            index) {
                          final a = state
                              .accounts[
                              index];
                          final email =
                              a['correo']
                                      ?.toString() ??
                                  '';
                          final nombres =
                              a['nombres']
                                      ?.toString() ??
                                  '';
                          final apellidos =
                              a['apellidos']
                                      ?.toString() ??
                                  '';
                          final displayName =
                              '$nombres $apellidos'
                                  .trim();
                          final activo = a['estado']
                                      ?.toString() ==
                                  'activo';

                          return Card(
                            margin: const EdgeInsets
                                .only(
                                bottom:
                                    12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(16)),
                            child:
                                ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal:
                                      16,
                                  vertical:
                                      8),
                              leading: CircleAvatar(
                                backgroundColor: activo
                                    ? Colors
                                        .teal
                                        .withOpacity(0.15)
                                    : Colors
                                        .orange
                                        .withOpacity(0.15),
                                child: Icon(
                                  Icons
                                      .account_circle,
                                  color: activo
                                      ? Colors
                                          .teal
                                      : Colors
                                          .orange,
                                ),
                              ),
                              title: Text(
                                displayName,
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600),
                              ),
                              subtitle: Text(
                                email.isNotEmpty ? email : 'Sin email',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                              trailing: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  if (!activo)
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors.orange.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Bloqueada',
                                        style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () =>
                                  _verDetalle(a),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox
                      .shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSearch() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType
                .emailAddress,
            decoration: InputDecoration(
              hintText:
                  'correo@ejemplo.com',
              prefixIcon:
                  const Icon(Icons.email),
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12)),
              contentPadding: const EdgeInsets
                  .symmetric(
                  horizontal: 16,
                  vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: _buscar,
          style: FilledButton.styleFrom(
            backgroundColor:
                const Color(0xFF04345C),
            padding: const EdgeInsets
                .symmetric(
                horizontal: 20,
                vertical: 14),
          ),
          child: const Icon(
              Icons.search),
        ),
      ],
    );
  }

  Widget _buildLocationSearch() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller:
                _manzanaCtrl,
            decoration: InputDecoration(
              hintText: 'Manzana',
              prefixIcon: const Icon(
                  Icons.grid_view),
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12)),
              contentPadding: const EdgeInsets
                  .symmetric(
                  horizontal: 16,
                  vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _villaCtrl,
            decoration: InputDecoration(
              hintText: 'Villa',
              prefixIcon: const Icon(
                  Icons.home),
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(12)),
              contentPadding: const EdgeInsets
                  .symmetric(
                  horizontal: 16,
                  vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: _buscar,
          style: FilledButton.styleFrom(
            backgroundColor:
                const Color(0xFF04345C),
            padding: const EdgeInsets
                .symmetric(
                horizontal: 20,
                vertical: 14),
          ),
          child: const Icon(
              Icons.search),
        ),
      ],
    );
  }
}

class _AccountDetailPage
    extends StatelessWidget {
  final Map<String, dynamic> account;
  final VoidCallback onBloquear;
  final VoidCallback onDesbloquear;
  final VoidCallback onEliminar;
  final VoidCallback onResetPassword;

  const _AccountDetailPage({
    required this.account,
    required this.onBloquear,
    required this.onDesbloquear,
    required this.onEliminar,
    required this.onResetPassword,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email =
        account['correo']
                ?.toString() ??
            '';
    final nombres =
        account['nombres']
                ?.toString() ??
            '';
    final apellidos =
        account['apellidos']
                ?.toString() ??
            '';
    final displayName =
        '$nombres $apellidos'
            .trim();
    final tipo =
        account['tipo']
                ?.toString() ??
            '';
    final tipoLabel = tipo ==
            'residente'
        ? 'Residente'
        : tipo ==
                'miembro_familia'
            ? 'Miembro de familia'
            : tipo;
    final activo = account['estado']
            ?.toString() ==
        'activo';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Detalle de Cuenta'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              if (activo)
                const PopupMenuItem(
                  value: 'block',
                  child: ListTile(
                    leading: Icon(
                        Icons.block,
                        color:
                            Colors.orange),
                    title: Text(
                        'Bloquear'),
                    contentPadding:
                        EdgeInsets.zero,
                  ),
                )
              else
                const PopupMenuItem(
                  value: 'unblock',
                  child: ListTile(
                    leading: Icon(
                        Icons.check_circle,
                        color:
                            Colors.green),
                    title: Text(
                        'Desbloquear'),
                    contentPadding:
                        EdgeInsets.zero,
                  ),
                ),
              // const PopupMenuItem(
              //   value: 'reset',
              //   child: ListTile(
              //     leading: Icon(
              //         Icons.lock_reset,
              //         color: Colors.blue),
              //     title: Text(
              //         'Restablecer contraseña'),
              //     contentPadding:
              //         EdgeInsets.zero,
              //   ),
              // ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                      Icons.delete,
                      color: Colors.red),
                  title:
                      Text('Eliminar'),
                  contentPadding:
                      EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (action) {
              switch (action) {
                case 'block':
                  onBloquear();
                case 'unblock':
                  onDesbloquear();
                case 'reset':
                  onResetPassword();
                case 'delete':
                  onEliminar();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors
                    .teal
                    .withOpacity(0.15),
                child: Text(
                  displayName.isNotEmpty
                      ? displayName[0]
                          .toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.teal,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                  height: 12),
              Text(displayName,
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                          fontWeight:
                              FontWeight
                                  .bold)),
              const SizedBox(
                  height: 4),
              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration:
                    BoxDecoration(
                  color: activo
                      ? Colors.green
                          .withOpacity(
                              0.15)
                      : Colors.orange
                          .withOpacity(
                              0.15),
                  borderRadius:
                      BorderRadius
                          .circular(12),
                ),
                child: Text(
                  activo
                      ? 'Activa'
                      : 'Bloqueada',
                  style: TextStyle(
                    color: activo
                        ? Colors.green
                        : Colors.orange,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 32),
          _sectionTitle(context,
              'Información de la Cuenta'),
          const SizedBox(height: 12),
          _detailCard(context, [
            _DetailField('Nombre', displayName),
            _DetailField('Correo',
                email.isNotEmpty ? email : '—'),
            _DetailField(
              'Identificación',
              account['identificacion']?.toString(),
            ),
            _DetailField(
              'Celular',
              account['celular']?.toString(),
            ),
            _DetailField(
                'Tipo', tipoLabel),
            _DetailField(
              'Estado',
              activo ? 'Activa' : 'Bloqueada',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(
              fontWeight:
                  FontWeight.bold),
    );
  }

  Widget _detailCard(
    BuildContext context,
    List<_DetailField> fields,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: fields
              .map((f) => Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                            vertical: 8),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(
                            f.label,
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                              fontWeight:
                                  FontWeight
                                      .w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            f.value ??
                                '—',
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w500),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _DetailField {
  final String label;
  final String? value;
  const _DetailField(
      this.label, this.value);
}
