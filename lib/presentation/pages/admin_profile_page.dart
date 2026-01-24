import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_event.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../widgets/admin_scaffold.dart';
import '../routes/app_routes.dart';
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
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool isEditing = false;
  bool notificationsEnabled = true;
  String editedEmail = '';
  String error = '';
  bool showSuccess = false;

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  void _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (ok == true) {
      context.read<AuthBloc>().add(LogoutRequested());
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AdminScaffold(
      title: 'Perfil',
      routeName: '/adminProfile',
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
              // Ya estamos aquí
              break;
          }
        });
      },
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthSuccess) {
            return const Center(child: Text('Error: No autenticado'));
          }

          final user = state.user;
          final nombres = user['nombres'] as String? ?? '—';
          final apellidos = user['apellidos'] as String? ?? '—';
          final correo = user['correo'] as String? ?? '—';
          final identificacion = user['identificacion'] as String? ?? widget.identificacion;
          final rol = user['rol'] as String? ?? 'administrador';
          final estado = user['estado'] as String? ?? 'activo';

          if (!isEditing) {
            editedEmail = correo != '—' ? correo : '';
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Toggle tema
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => ThemeController.toggle(),
                    icon: Icon(
                      Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              // Header del perfil
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$nombres $apellidos',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text('Administrador'),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Información Personal
              Text(
                'Información Personal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Tarjeta de información
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoRow(context, Icons.badge, 'Identificación', identificacion),
                      const Divider(height: 24),
                      _infoRow(context, Icons.person, 'Nombres', nombres),
                      const Divider(height: 24),
                      _infoRow(context, Icons.person_outline, 'Apellidos', apellidos),
                      const Divider(height: 24),
                      _infoRow(context, Icons.verified_user, 'Estado', estado),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Correo Electrónico
              Text(
                'Correo Electrónico',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Correo',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    correo,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => setState(() {
                                isEditing = true;
                                editedEmail = correo != '—' ? correo : '';
                                error = '';
                              }),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            TextField(
                              controller: TextEditingController(text: editedEmail),
                              onChanged: (value) => setState(() => editedEmail = value),
                              decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            if (error.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  error,
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => setState(() {
                                      isEditing = false;
                                      error = '';
                                    }),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (editedEmail.isEmpty || _isValidEmail(editedEmail)) {
                                        // TODO: Implementar actualización de correo
                                        setState(() {
                                          isEditing = false;
                                          showSuccess = true;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Correo actualizado exitosamente'),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      } else {
                                        setState(() => error = 'Por favor ingrese un correo válido');
                                      }
                                    },
                                    child: const Text('Guardar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Preferencias
              Text(
                'Preferencias',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Notificaciones'),
                      Switch(
                        value: notificationsEnabled,
                        onChanged: (value) => setState(() => notificationsEnabled = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón de Cerrar Sesión
              ElevatedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 32),

              // Footer con versión
              Center(
                child: Text(
                  'Versión 2.0.0 - Admin',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
