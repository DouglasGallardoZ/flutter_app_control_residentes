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
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (ctx, state) {
                    if (state is AuthSuccess) {
                      final rol = state.user['rol'];
                      final personaId = state.user['personaId'] as int;
                      final identificacion = state.user['identificacion'] as String;
                      final vivienda = state.user['vivienda'] as Map<String, dynamic>?;
                      final nombres = state.user['nombres'] as String?;
                      final apellidos = state.user['apellidos'] as String?;
                      final nombreCompleto =
                          nombres != null && apellidos != null
                              ? '$nombres $apellidos'
                              : 'Usuario';

                      // Navegar según rol
                      if (rol == 'residente') {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.residentDashboard,
                          arguments: {
                            'personaId': personaId,
                            'identificacion': identificacion,
                            'residenceId':
                                '${vivienda?['manzana']}-${vivienda?['villa']}',
                            'userName': nombreCompleto,
                          },
                        );
                      } else if (rol == 'miembro_familia') {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.familyDashboard,
                          arguments: {
                            'personaId': personaId,
                            'identificacion': identificacion,
                            'userName': nombreCompleto,
                          },
                        );
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.adminDashboard,
                          arguments: {
                            'personaId': personaId,
                            'identificacion': identificacion,
                            'userName': nombreCompleto,
                          },
                        );
                      }
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (ctx, state) {
                    final loading = state is AuthLoading;
                    return Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield,
                            size: 48,
                            color: Color(0xFF3B82F6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bienvenido',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingrese sus credenciales para continuar',
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              hintText: 'usuario@example.com',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingrese su correo';
                              }
                              if (!v.contains('@')) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Ingrese su contraseña',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingrese su contraseña';
                              }
                              if (v.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                              LoginSubmitted(
                                                emailCtrl.text.trim(),
                                                passCtrl.text.trim(),
                                              ),
                                            );
                                      }
                                    },
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Ingresar'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
