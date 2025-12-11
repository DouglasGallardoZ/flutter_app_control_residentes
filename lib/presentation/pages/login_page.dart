import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../routes/app_routes.dart';
import '../blocs/session/session_cubit.dart';
import '../../core/constants/roles.dart';

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
            ctx.read<SessionCubit>().setUser(state.user);
            final role = state.user['role'];
            if (role == Roles.admin) {
              Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
            } else if (role == Roles.resident) {
              Navigator.pushReplacementNamed(context, AppRoutes.residentDashboard);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.familyDashboard);
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (ctx, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: idCtrl,
                decoration: const InputDecoration(labelText: 'Identificación (10 dígitos)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              if (state is AuthLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: () => context.read<AuthBloc>().add(
                        LoginSubmitted(idCtrl.text.trim(), passCtrl.text),
                      ),
                  child: const Text('Ingresar'),
                ),
            ],
          );
        },
      ),
    );
  }
}
