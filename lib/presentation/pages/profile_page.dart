import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_event.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../widgets/app_scaffold.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
    final maybeResidenceId = routeArgs?['residenceId'] as String?;
    final maybeUserId = routeArgs?['userId'] as String?;
    final authState = context.read<AuthBloc>().state;
    String? authUserId;
    String? authResidence;
    String? authName;
    if (authState is AuthSuccess) {
      authUserId = (authState.user['id'] ?? authState.user['uid']) as String?;
      authResidence = authState.user['residence'] as String?;
      authName = authState.user['name'] as String?;
    }

    return AppScaffold(
      title: 'Mi Perfil',
      currentIndex: 4,
      onTabSelected: (i) {
        switch (i) {
          case 0:
            final uid = maybeUserId ?? authUserId;
            final rid = maybeResidenceId ?? authResidence;
            final uname = routeArgs?['userName'] as String? ?? authName;
            if (uid != null && rid != null && uname != null) {
              Navigator.pushReplacementNamed(context, '/residentDashboard', arguments: {'userId': uid, 'residenceId': rid, 'userName': uname});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos para ir a Inicio')));
            }
            break;
          case 1:
            final uid2 = maybeUserId ?? authUserId;
            final uname2 = routeArgs?['userName'] as String? ?? authName;
            if (uid2 != null && uname2 != null) Navigator.pushReplacementNamed(context, '/qrSelf', arguments: {'userId': uid2, 'userName': uname2}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 2:
            final uid3 = maybeUserId ?? authUserId;
            if (uid3 != null) Navigator.pushReplacementNamed(context, '/accessHistory', arguments: {'userId': uid3}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 3:
            final uid4 = maybeUserId ?? authUserId;
            final rid4 = maybeResidenceId ?? authResidence;
            if (uid4 != null && rid4 != null) Navigator.pushReplacementNamed(context, '/familyDashboard', arguments: {'userId': uid4, 'residenceId': rid4}); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan datos')));
            break;
          case 4: break;
        }
      },
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, state) {
          if (state is! AuthSuccess) return const Center(child: Text('No hay sesión activa'));
          final emailCtrl = TextEditingController(text: state.user['email'] ?? '');
          final name = state.user['name'] ?? '';
          final role = (state.user['role'] ?? '') as String;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    Text(role[0].toUpperCase() + role.substring(1)),
                    const SizedBox(height: 12),
                    ListTile(leading: const Icon(Icons.badge), title: const Text('Identificación'), subtitle: Text(userId)),
                    ListTile(leading: const Icon(Icons.email_outlined), title: const Text('Correo Electrónico'), subtitle: TextField(controller: emailCtrl)),
                    ListTile(leading: const Icon(Icons.home_work_outlined), title: const Text('Residencia'), subtitle: Text(state.user['residence'] ?? '—')),
                  ]),
                ),
              ),
              Card(
                child: SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Notificaciones'),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // Conectar a UpdateEmailUseCase vía un bloc dedicado si lo tienes
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo actualizado')));
                },
                child: const Text('Actualizar correo'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => ctx.read<AuthBloc>().add(LogoutRequested()),
                child: const Text('Cerrar Sesión'),
              ),
              const SizedBox(height: 12),
              const Center(child: Text('Versión 1.0.0 © 2025 Acceso Residencial')),
            ],
          );
        },
      ),
    );
  }
}
