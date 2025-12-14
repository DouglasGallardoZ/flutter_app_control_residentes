import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_event.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthSuccess) {
            final userId = state.user['id'] as String?; // o usa 'uid' si es lo que manejas
            if (userId == null || userId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión iniciada, pero falta userId')),
              );
              return;
            }

            final role = state.user['role'];
            if (role == 'admin') {
              Navigator.pushNamed(context, AppRoutes.adminDashboard, arguments: userId);
            } else if (role == 'resident') {
              Navigator.pushNamed(context, AppRoutes.residentDashboard, arguments: userId);
            } else {
              Navigator.pushNamed(context, AppRoutes.familyDashboard, arguments: userId);
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (ctx, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Identificación')),
              const SizedBox(height: 12),
              TextFormField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
              const SizedBox(height: 20),
              if (state is AuthLoading) const Center(child: CircularProgressIndicator())
              else ElevatedButton(
                onPressed: () => context.read<AuthBloc>().add(LoginSubmitted(idCtrl.text.trim(), passCtrl.text.trim())),
                child: const Text('Ingresar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
