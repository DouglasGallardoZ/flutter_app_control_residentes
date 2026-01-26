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
  bool showPassword = false;

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.light
                ? const [Color(0xFFFFFFFF), Color(0xFFDCDBE5)]
                : const [Color(0xFF1A1A2E), Color(0xFF2D1B3D)],
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
                      // Lógica de navegación en la capa de presentación
                      final rol = state.user['rol'] as String? ?? 'residente';
                      final personaId = state.user['personaId'] as int? ?? 0;
                      final identificacion = state.user['identificacion'] as String? ?? '';
                      final vivienda = state.user['vivienda'] as Map<String, dynamic>?;
                      final nombreCompleto = state.user['name'] as String? ?? 'Usuario';
                      final residenceId = vivienda != null ? '${vivienda['manzana']}-${vivienda['villa']}' : '';

                      final args = {
                        'personaId': personaId,
                        'identificacion': identificacion,
                        'residenceId': residenceId,
                        'userName': nombreCompleto,
                      };

                      // Determinar ruta según rol
                      late final String route;
                      switch (rol.toLowerCase()) {
                        case 'residente':
                          route = AppRoutes.residentDashboard;
                          break;
                        case 'miembro_familia':
                        case 'family':
                          route = AppRoutes.familyDashboard;
                          break;
                        case 'admin':
                        case 'administrador':
                          route = AppRoutes.adminDashboard;
                          break;
                        default:
                          route = AppRoutes.residentDashboard;
                      }

                      Navigator.pushReplacementNamed(ctx, route, arguments: args);
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
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
                      child: SingleChildScrollView(
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
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Ingrese su contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () => setState(() => showPassword = !showPassword),
                              ),
                            ),
                            obscureText: !showPassword,
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
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(
                            '¿No tienes cuenta?',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: loading
                                  ? null
                                  : () {
                                      Navigator.of(context)
                                          .pushNamed('/registerOption');
                                    },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Crear Cuenta'),
                            ),
                          ),
                        ],
                        ),
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
