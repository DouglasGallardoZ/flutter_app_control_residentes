import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_event.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../application/blocs/security_session/security_session_bloc.dart';
import '../../application/blocs/security_session/security_session_event.dart';
import '../widgets/admin_scaffold.dart';
import '../theme/theme_controller.dart';

class AdminProfilePage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminProfilePage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminProfilePage> createState() =>
      _AdminProfilePageState();
}

class _AdminProfilePageState
    extends State<AdminProfilePage> {
  final _emailCtrl =
      TextEditingController();
  bool _editandoEmail = false;
  bool _notificacionesActivas =
      true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmarCerrarSesion() async {
    final confirmado =
        await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout,
            color: Colors.red,
            size: 48),
        title: const Text(
            'Cerrar Sesión'),
        content: const Text(
            '¿Estás seguro de cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    ctx, false),
            child: const Text(
                'Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(
                    ctx, true),
            style: FilledButton
                .styleFrom(
                    backgroundColor:
                        Colors.red),
            child: const Text(
                'Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmado == true &&
        context.mounted) {
      context
          .read<AuthBloc>()
          .add(LogoutRequested());
      context
          .read<SecuritySessionBloc>()
          .add(SessionTerminated());
      Navigator.of(context)
          .pushNamedAndRemoveUntil(
              '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminScaffold(
      title: 'Mi Perfil',
      routeName: '/adminProfile',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.of(context)
              .pushReplacementNamed(
        '/adminDashboard',
        arguments: {
          'personaId':
              widget.personaId,
          'identificacion':
              widget.identificacion,
        },
      ),
      onTabSelected: (i) {
        if (i == 2) return;
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          final routes = [
            '/adminDashboard',
            // TODO: Restaurar cuando se implemente el módulo de historial
            // '/adminAccessHistory',
            '/adminUsers',
            null,
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
      body: BlocBuilder<AuthBloc,
          AuthState>(
        builder: (context,
            authState) {
          if (authState
              is! AuthSuccess) {
            return Center(
              child: authState
                      is AuthFailure
                  ? Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons
                              .cloud_off,
                          size: 48,
                          color: theme
                              .colorScheme
                              .error,
                        ),
                        const SizedBox(
                            height:
                                16),
                        Text(authState.message,
                            textAlign:
                                TextAlign
                                    .center),
                        const SizedBox(
                            height:
                                24),
                        ElevatedButton
                            .icon(
                          onPressed:
                              () =>
                                  context
                                      .read<AuthBloc>()
                                      .add(CheckAuthStatus()),
                          icon: const Icon(
                              Icons
                                  .refresh),
                          label: const Text(
                              'Reintentar'),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            );
          }

          final user =
              authState.user;
          final nombres =
              user['nombres']
                      as String? ??
                  '';
          final apellidos =
              user['apellidos']
                      as String? ??
                  '';
          final identificacion =
              user['identificacion']
                      as String? ??
                  '';
          final email =
              user['email']
                      as String? ??
                  '';

          if (!_editandoEmail &&
              email.isNotEmpty) {
            _emailCtrl.text =
                email;
          }

          return ListView(
            padding:
                const EdgeInsets
                    .all(24),
            children: [
              Center(
                child: Column(
                    children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: theme
                        .colorScheme
                        .primary
                        .withOpacity(
                            0.15),
                    child: Text(
                      nombres.isNotEmpty
                          ? nombres[0]
                              .toUpperCase()
                          : 'A',
                      style: TextStyle(
                        fontSize:
                            36,
                        color: theme
                            .colorScheme
                            .primary,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 16),
                  Text(
                    '$nombres $apellidos'
                        .trim(),
                    style: theme
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .bold),
                  ),
                  const SizedBox(
                      height: 8),
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal:
                          16,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: const Color(
                              0xFF04345C)
                          .withOpacity(
                              0.1),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),
                    child: const Text(
                      'Administrador',
                      style: TextStyle(
                        color: Color(
                            0xFF04345C),
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize:
                            13,
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(
                  height: 32),
              Text(
                'Información Personal',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                        fontWeight:
                            FontWeight
                                .bold),
              ),
              const SizedBox(
                  height: 12),
              Card(
                elevation: 2,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets
                          .all(16),
                  child: Column(
                    children: [
                      _infoRow(
                          context,
                          'Identificación',
                          identificacion),
                      const Divider(),
                      _infoRow(
                          context,
                          'Nombres',
                          nombres),
                      const Divider(),
                      _infoRow(
                          context,
                          'Apellidos',
                          apellidos),
                      const Divider(),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          SizedBox(
                            width:
                                110,
                            child: Text(
                              'Correo',
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
                            child: _editandoEmail
                                ? Row(
                                    children: [
                                      Expanded(
                                        child:
                                            TextField(
                                          controller:
                                              _emailCtrl,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => setState(() => _editandoEmail = false),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          _emailCtrl.text = email;
                                          setState(() => _editandoEmail = false);
                                        },
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child:
                                            Text(
                                          email.isNotEmpty
                                              ? email
                                              : '—',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.edit,
                                            size: 18),
                                        onPressed: () => setState(
                                            () => _editandoEmail = true),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                  height: 24),
              Text(
                'Preferencias',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                        fontWeight:
                            FontWeight
                                .bold),
              ),
              const SizedBox(
                  height: 12),
              Card(
                elevation: 2,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value:
                          _notificacionesActivas,
                      onChanged: (v) =>
                          setState(() =>
                              _notificacionesActivas =
                                  v),
                      title: const Text(
                          'Notificaciones Push'),
                      subtitle: const Text(
                          'Recibir notificaciones en tiempo real'),
                      secondary:
                          const Icon(
                              Icons
                                  .notifications_active),
                      activeColor:
                          const Color(
                              0xFF04345C),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    const Divider(
                        height: 1),
                    SwitchListTile(
                      value: theme.brightness ==
                          Brightness
                              .dark,
                      onChanged: (v) =>
                          ThemeController
                              .toggle(),
                      title: const Text(
                          'Tema Oscuro'),
                      subtitle: const Text(
                          'Activar modo oscuro'),
                      secondary: const Icon(
                          Icons
                              .dark_mode),
                      activeColor:
                          const Color(
                              0xFF04345C),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                  height: 32),
              SizedBox(
                width:
                    double.infinity,
                child: OutlinedButton
                    .icon(
                  onPressed:
                      _confirmarCerrarSesion,
                  icon: const Icon(
                      Icons.logout,
                      color:
                          Colors.red),
                  label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                          color: Colors
                              .red)),
                  style: OutlinedButton
                      .styleFrom(
                    side: const BorderSide(
                        color:
                            Colors.red),
                    padding:
                        const EdgeInsets
                            .symmetric(
                            vertical:
                                16),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  12),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                  height: 24),
              Center(
                child: Text(
                  'Guardin Admin v1.0',
                  style: TextStyle(
                    color: Colors
                        .grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
              vertical: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors
                    .grey.shade600,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty
                  ? value
                  : '—',
              style: const TextStyle(
                  fontWeight:
                      FontWeight
                          .w500),
            ),
          ),
        ],
      ),
    );
  }
}
