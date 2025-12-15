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
    return AppScaffold(
      title: 'Mi Perfil',
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
