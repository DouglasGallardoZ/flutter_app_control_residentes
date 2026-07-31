import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_event.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../application/blocs/account/account_bloc.dart';
import '../../application/blocs/account/account_event.dart';
import '../../application/blocs/account/account_state.dart';
import '../../application/blocs/security_session/security_session_bloc.dart';
import '../../application/blocs/security_session/security_session_event.dart';
import '../widgets/app_scaffold.dart';
import '../routes/app_routes.dart';
import '../theme/theme_controller.dart';

class ProfilePage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const ProfilePage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool notificationsEnabled = true;
  String editedEmail = '';
  String error = '';
  bool isSavingEmail = false;
  TextEditingController? _emailCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl?.dispose();
    super.dispose();
  }

  /// Convierte el código de rol a nombre legible
  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return 'Administrador';
      case 'resident':
      case 'residente':
        return 'Residente';
      case 'family':
      case 'miembro_familia':
      case 'miembro de familia':
        return 'Miembro de Familia';
      default:
        return role;
    }
  }

  /// Verifica si el rol es de miembro de familia
  bool _isFamilyMemberRole(String? role) {
    if (role == null) return false;
    final lower = role.toLowerCase();
    return lower == 'family' ||
        lower == 'miembro_familia' ||
        lower == 'miembro de familia';
  }

  /// Valida formato de email
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  /// Extrae la dirección de la vivienda desde el estado del BLoC
  String _extractResidenceFromState(Map<String, dynamic> userState) {
    try {
      if (userState['vivienda'] != null) {
        final vivienda = userState['vivienda'] as Map<String, dynamic>;
        final manzana = vivienda['manzana'] ?? '';
        final villa = vivienda['villa'] ?? '';
        if (manzana.isNotEmpty && villa.isNotEmpty) {
          return 'Manzana $manzana, Villa $villa';
        }
      }
      if (userState['residence'] != null &&
          (userState['residence'] as String).isNotEmpty) {
        return userState['residence'] as String;
      }
    } catch (e) {
      // Fallar silenciosamente y retornar default
    }
    return '—';
  }

  /// Envía cambio de email al AccountBloc
  void _submitEmailChange(AuthSuccess authState) {
    setState(() {
      error = '';
    });

    if (editedEmail.isNotEmpty && !_isValidEmail(editedEmail)) {
      setState(() {
        error = 'Por favor ingrese un correo electrónico válido';
      });
      return;
    }

    setState(() {
      isSavingEmail = true;
    });
    context.read<AccountBloc>().add(
          UpdateEmailSubmitted(widget.personaId.toString(), editedEmail),
        );
  }

  /// Muestra diálogo de confirmación para logout
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true && mounted) {
      context.read<AuthBloc>().add(LogoutRequested());
      context.read<SecuritySessionBloc>().add(SessionTerminated());
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final maybeResidenceId = routeArgs?['residenceId'] as String?;
    final maybeUserId = routeArgs?['userId'] as String?;
    final theme = Theme.of(context);

    final authState = context.read<AuthBloc>().state;

    // Variables para navegación tab
    bool isFamilyMember = false;
    String? authUserId;
    String? authResidence;
    String? authName;
    String? authPersonaId;

    if (authState is AuthSuccess) {
      final role = authState.user['rol'] as String?;
      isFamilyMember = _isFamilyMemberRole(role);
      
      // Obtener identificadores del usuario
      authPersonaId = (authState.user['personaId'] ?? authState.user['uid'])?.toString();
      authUserId = authPersonaId;
      authName = authState.user['name'] ?? authState.user['nombres'] as String?;
      
      // Extraer residencia desde vivienda
      authResidence = _extractResidenceFromState(authState.user);
    }

    return AppScaffold(
      title: 'Mi Perfil',
      routeName: '/profile',
      onTabSelected: (i) {
        if (isFamilyMember && i == 3) return;
        if (!isFamilyMember && i == 4) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (i) {
            case 0:
              final uid = maybeUserId ?? authUserId;
              final rid = maybeResidenceId ?? authResidence;
              final uname = routeArgs?['userName'] as String? ?? authName;
              if (uid != null && rid != null && uname != null) {
                final route = isFamilyMember
                    ? AppRoutes.familyDashboard
                    : AppRoutes.residentDashboard;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  route,
                  (route) => false,
                  arguments: {
                    'personaId': uid,
                    'identificacion': uid,
                    'residenceId': rid,
                    'userName': uname
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Faltan datos para ir a Inicio'),
                  ),
                );
              }
              break;
            case 1:
              final uid2 = maybeUserId ?? authUserId;
              final ident2 = widget.identificacion;
              if (uid2 != null && ident2.isNotEmpty) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.qrSelf,
                  (route) => false,
                  arguments: {
                    'personaId': int.tryParse(uid2) ?? 0,
                    'identificacion': ident2,
                    'residenceId': maybeResidenceId ?? authResidence,
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Faltan datos')),
                );
              }
              break;
            case 2:
              final uid3 = maybeUserId ?? authUserId;
              final ident3 = widget.identificacion;
              if (uid3 != null && ident3.isNotEmpty) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.accessHistory,
                  (route) => false,
                  arguments: {
                    'personaId': int.tryParse(uid3) ?? 0,
                    'identificacion': ident3,
                    'residenceId': maybeResidenceId ?? authResidence,
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Faltan datos')),
                );
              }
              break;
            case 3:
              if (!isFamilyMember) {
                final uid4 = maybeUserId ?? authUserId;
                final ident4 = widget.identificacion;
                final rid4 = maybeResidenceId ?? authResidence;
                if (uid4 != null && ident4.isNotEmpty && rid4 != null) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.members,
                    (route) => false,
                    arguments: {
                      'personaId': int.tryParse(uid4) ?? 0,
                      'identificacion': ident4,
                      'residenceId': rid4,
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Faltan datos')),
                  );
                }
              }
              break;
          }
        });
      },
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, state) {
          if (state is! AuthSuccess) {
            return const Center(child: Text('No hay sesión activa'));
          }

            // Extraer datos del usuario desde el estado del AuthBloc
            final userMap = state.user;
            final fullName = userMap['name'] ?? '—';
            final nombres = userMap['nombres'] as String? ?? fullName;
            final apellidos = userMap['apellidos'] as String? ?? '';
            final role = (userMap['role'] ?? userMap['rol'] ?? '') as String;
            final email = userMap['email'] ?? '—';
            final residence = _extractResidenceFromState(userMap);
            final isFamilyRole = _isFamilyMemberRole(role);

            // Actualizar email editado si no estamos en modo edición
            if (!isEditing) {
              editedEmail = email != '—' ? email : '';
            }

            return BlocConsumer<AccountBloc, AccountState>(
              listener: (ctx2, accState) {
                if (accState is AccountUpdated) {
                  setState(() {
                    isSavingEmail = false;
                    isEditing = false;
                  });
                  ScaffoldMessenger.of(ctx2).showSnackBar(
                    const SnackBar(
                      content: Text('Correo actualizado exitosamente'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else if (accState is AccountError) {
                  setState(() {
                    isSavingEmail = false;
                    error = accState.message;
                  });
                  ScaffoldMessenger.of(ctx2).showSnackBar(
                    SnackBar(content: Text(accState.message)),
                  );
                }
              },
              builder: (ctx2, accState) {
                return _buildProfileContent(
                  theme: theme,
                  nombres: nombres,
                  apellidos: apellidos,
                  role: role,
                  email: email,
                  residence: residence,
                  isFamilyRole: isFamilyRole,
                  authState: state,
                );
              },
            );
          },
        ),
      );
    }

  /// Construye el contenido principal del perfil
  Widget _buildProfileContent({
    required ThemeData theme,
    required String nombres,
    required String apellidos,
    required String role,
    required String email,
    required String residence,
    required bool isFamilyRole,
    required AuthSuccess authState,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileHeader(
          theme: theme,
          nombres: nombres,
          apellidos: apellidos,
          role: role,
        ),
        const SizedBox(height: 32),
        _buildInformationSection(
          theme: theme,
          nombres: nombres,
          apellidos: apellidos,
          residence: residence,
          isFamilyRole: isFamilyRole,
        ),
        const SizedBox(height: 24),
        _buildEmailSection(
          theme: theme,
          email: email,
          authState: authState,
        ),
        const SizedBox(height: 24),
        _buildPreferencesSection(theme: theme),
        const SizedBox(height: 24),
        _buildLogoutButton(theme: theme),
        const SizedBox(height: 32),
        _buildFooter(theme: theme),
      ],
    );
  }

  /// Encabezado del perfil con avatar e información básica
  Widget _buildProfileHeader({
    required ThemeData theme,
    required String nombres,
    required String apellidos,
    required String role,
  }) {
    return Center(
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
              _isFamilyMemberRole(role)
                  ? Icons.family_restroom
                  : Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            apellidos.isNotEmpty ? '$nombres $apellidos' : nombres,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Chip(
            label: Text(_getRoleDisplayName(role)),
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de información personal
  Widget _buildInformationSection({
    required ThemeData theme,
    required String nombres,
    required String apellidos,
    required String residence,
    required bool isFamilyRole,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Personal',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  context: context,
                  icon: Icons.badge,
                  label: 'Identificación',
                  value: widget.identificacion,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  context: context,
                  icon: Icons.person,
                  label: 'Nombres',
                  value: nombres,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  context: context,
                  icon: Icons.person_outline,
                  label: 'Apellidos',
                  value: apellidos.isNotEmpty ? apellidos : '—',
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  context: context,
                  icon: Icons.home_work_outlined,
                  label: 'Residencia',
                  value: residence,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Sección de correo electrónico
  Widget _buildEmailSection({
    required ThemeData theme,
    required String email,
    required AuthSuccess authState,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  _buildEmailViewMode(theme: theme, email: email)
                else
                  _buildEmailEditMode(
                    theme: theme,
                    authState: authState,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Vista de lectura del correo
  Widget _buildEmailViewMode({
    required ThemeData theme,
    required String email,
  }) {
    return Row(
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
                email,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        // IconButton(
        //   icon: const Icon(Icons.edit),
        //   onPressed: () => setState(() {
        //     isEditing = true;
        //     editedEmail = email != '—' ? email : '';
        //     _emailCtrl?.text = editedEmail;
        //     error = '';
        //   }),
        // ),
      ],
    );
  }

  /// Vista de edición del correo
  Widget _buildEmailEditMode({
    required ThemeData theme,
    required AuthSuccess authState,
  }) {
    return Column(
      children: [
        TextField(
          controller: _emailCtrl,
          onChanged: (value) => editedEmail = value,
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
                onPressed: isSavingEmail
                    ? null
                    : () {
                        if (editedEmail.isEmpty ||
                            _isValidEmail(editedEmail)) {
                          _submitEmailChange(authState);
                        } else {
                          setState(() {
                            error = 'Por favor ingrese un correo válido';
                          });
                        }
                      },
                child: isSavingEmail
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Sección de preferencias
  Widget _buildPreferencesSection({required ThemeData theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notificaciones'),
                    Switch(
                      value: notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => notificationsEnabled = value),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tema Oscuro'),
                    Switch(
                      value: theme.brightness == Brightness.dark,
                      onChanged: (value) => ThemeController.toggle(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Botón de cerrar sesión
  Widget _buildLogoutButton({required ThemeData theme}) {
    return ElevatedButton.icon(
      onPressed: _confirmLogout,
      icon: const Icon(Icons.logout),
      label: const Text('Cerrar Sesión'),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// Footer con versión
  Widget _buildFooter({required ThemeData theme}) {
    return Center(
      child: Text(
        'Versión 2.0.0',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.hintColor,
        ),
      ),
    );
  }

  /// Fila de información genérica
  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
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
