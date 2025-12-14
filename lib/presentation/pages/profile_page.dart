import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_event.dart';
import '../../application/blocs/auth/auth_state.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, state) {
          if (state is AuthSuccess) {
            emailCtrl.text = state.user['email'] ?? '';
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('ID: ${state.user['id']}'),
                Text('Nombre: ${state.user['name']}'),
                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Correo')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // aquí llamarías a UpdateEmailUseCase vía otro bloc
                  },
                  child: const Text('Actualizar correo'),
                ),
                ElevatedButton(
                  onPressed: () => ctx.read<AuthBloc>().add(LogoutRequested()),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            );
          }
          return const Center(child: Text('No hay sesión activa'));
        },
      ),
    );
  }
}
