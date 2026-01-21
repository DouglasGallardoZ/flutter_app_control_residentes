import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_event.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../application/blocs/account/account_bloc.dart';
import '../../application/blocs/account/account_event.dart';
import '../../application/blocs/account/account_state.dart';
import '../widgets/app_scaffold.dart';
import '../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  const ProfilePage({super.key, required this.personaId, required this.identificacion});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool notificationsEnabled = true;
  String editedEmail = '';
  String error = '';
  bool showSuccess = false;
  bool isSavingEmail = false;

  String _roleName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'resident':
        return 'Residente';
      case 'family':
        return 'Miembro de Familia';
      default:
        return role;
    }
  }

  bool _isValidEmail(String e) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(e);
  }

  void _saveEmail(AuthSuccess state) {
    setState(() { error = ''; });
    if (editedEmail.isNotEmpty && !_isValidEmail(editedEmail)) {
      setState(() { error = 'Por favor ingrese un correo electrónico válido'; });
      return;
    }
    // Dispatch update to AccountBloc
    setState(() { isSavingEmail = true; });
    context.read<AccountBloc>().add(UpdateEmailSubmitted(widget.personaId.toString(), editedEmail));
  }

  void _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: const Text('Cerrar Sesión')),
        ],
      ),
    );
    if (ok == true) {
      context.read<AuthBloc>().add(LogoutRequested());
      // Navigate immediately to login and clear navigation stack; AuthBloc will perform sign-out
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
    final maybeResidenceId = routeArgs?['residenceId'] as String?;
    final maybeUserId = routeArgs?['userId'] as String?;
    
    final authState = context.read<AuthBloc>().state;
    
    // Obtener rol desde AuthBloc (determina si es miembro familiar)
    bool isFamilyMember = false;
    String? authUserId;
    String? authResidence;
    String? authName;
    if (authState is AuthSuccess) {
      final role = authState.user['rol'] as String?;
      isFamilyMember = role?.toLowerCase() == 'miembro_familia' || role?.toLowerCase() == 'family' || role?.toLowerCase() == 'miembro de familia';
      authUserId = (authState.user['id'] ?? authState.user['uid'])?.toString();
      authResidence = authState.user['residence'] as String?;
      authName = authState.user['name'] as String?;
      editedEmail = editedEmail.isEmpty ? (authState.user['email'] ?? '') as String : editedEmail;
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
                final route = isFamilyMember ? AppRoutes.familyDashboard : AppRoutes.residentDashboard;
                Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false, arguments: {'userId': uid, 'residenceId': rid, 'userName': uname});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Inicio')));
              }
              break;
            case 1:
              final uid2 = maybeUserId ?? authUserId;
              final uname2 = routeArgs?['userName'] as String? ?? authName;
              if (uid2 != null && uname2 != null) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.qrSelf, (route) => false, arguments: {'userId': uid2, 'userName': uname2}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
              break;
            case 2:
              final uid3 = maybeUserId ?? authUserId;
              if (uid3 != null) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.accessHistory, (route) => false, arguments: {'userId': uid3}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
              break;
            case 3:
              if (!isFamilyMember) {
                final uid4 = maybeUserId ?? authUserId;
                final rid4 = maybeResidenceId ?? authResidence;
                if (uid4 != null && rid4 != null) Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.members, (route) => false, arguments: {'userId': uid4, 'residenceId': rid4}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
              }
              break;
          }
        });
      },
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctxAuth, authState) {
          if (authState is AuthInitial) {
            // After logout, navigate to login and clear stack
            Navigator.pushNamedAndRemoveUntil(ctxAuth, AppRoutes.login, (r) => false);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (ctx, state) {
            if (state is! AuthSuccess) return const Center(child: Text('No hay sesión activa'));

            final name = state.user['name'] ?? '';
            final role = (state.user['role'] ?? '') as String;
            final residence = state.user['residence'] ?? '—';

            return BlocConsumer<AccountBloc, AccountState>(
            listener: (ctx2, accState) {
              if (accState is AccountUpdated) {
                setState(() {
                  isSavingEmail = false;
                  isEditing = false;
                  showSuccess = true;
                });
                ScaffoldMessenger.of(ctx2).showSnackBar(const SnackBar(content: Text('Correo actualizado'), behavior: SnackBarBehavior.floating));
                Future.delayed(const Duration(seconds: 2), () => setState(() => showSuccess = false));
              } else if (accState is AccountError) {
                setState(() { isSavingEmail = false; error = accState.message; });
                ScaffoldMessenger.of(ctx2).showSnackBar(SnackBar(content: Text(accState.message)));
              }
            },
            builder: (ctx2, accState) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Success toast
                  if (showSuccess)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(8)),
                      child: Row(children: const [Icon(Icons.check_circle, color: Color(0xFF10B981)), SizedBox(width: 8), Text('Perfil actualizado exitosamente')]),
                    ),

                  // Avatar card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(child: Column(children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                          child: Center(child: Text((name as String).isNotEmpty ? name[0].toUpperCase() : '?', style: Theme.of(context).textTheme.headlineMedium)),
                        ),
                        const SizedBox(height: 8),
                        Text(name, style: Theme.of(context).textTheme.titleLarge),
                        Text(_roleName(role), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
                      ])),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Personal info card (name + id)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Información Personal', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _infoRow(context, Icons.person, 'Nombre Completo', name),
                        const SizedBox(height: 8),
                        _infoRow(context, Icons.badge_outlined, 'Identificación', widget.identificacion),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Email card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          if (isEditing)
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'correo@ejemplo.com'),
                              onChanged: (v) => setState(() { editedEmail = v; error = ''; }),
                              controller: TextEditingController(text: editedEmail),
                            )
                          else
                            Text(state.user['email'] ?? 'No especificado'),
                          if (error.isNotEmpty) ...[const SizedBox(height: 6), Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error))]
                        ])),
                        const SizedBox(width: 8),
                        isSavingEmail ? const SizedBox(width:24, height:24, child: CircularProgressIndicator(strokeWidth:2)) : IconButton(
                          icon: Icon(isEditing ? Icons.save : Icons.edit, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            if (isEditing) {
                              _saveEmail(state);
                            } else {
                              setState(() => isEditing = true);
                            }
                          },
                        )
                      ]),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Residence card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _infoRow(context, Icons.home_work_outlined, 'Residencia', residence),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Notificaciones'),
                        Switch(value: notificationsEnabled, onChanged: (v) => setState(() => notificationsEnabled = v)),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Colors.white),
                  ),

                  const SizedBox(height: 12),
                  Center(child: Text('Versión 1.0.0', style: Theme.of(context).textTheme.bodySmall)),
                  Center(child: Text('© 2025 Acceso Residencial', style: Theme.of(context).textTheme.bodySmall)),
                ],
              );
            },
          );
        },
      ),
    ));
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(value)])),
    ]);
  }
}
