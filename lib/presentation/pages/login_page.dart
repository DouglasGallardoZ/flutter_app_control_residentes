import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_event.dart';
import '../../application/blocs/auth/auth_state.dart';
import '../../application/blocs/security_session/security_session_bloc.dart';
import '../../core/validations/format_rules.dart';
import '../../application/blocs/security_session/security_session_event.dart';
import '../../application/blocs/security_session/security_session_state.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../../domain/ports/notificacion_push_handler_port.dart';
import '../../injection.dart';
import '../routes/app_routes.dart';
import 'facial_verification_page.dart';

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
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatus());
    });
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _inicializarFCM(String usuarioId) {
    if (kIsWeb) return;
    final pushHandler =
        sl<NotificacionPushHandlerPort>();
    pushHandler.inicializar(usuarioId);
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
                  listener: (ctx, state) async {
                    if (state is AuthSuccess && !_isNavigating) {
                      _isNavigating = true;
                      try {
                        final rol = state.user['rol'] as String? ?? 'residente';
                        final personaId = state.user['personaId'] as int? ?? 0;
                        final identificacion = state.user['identificacion'] as String? ?? '';
                        final nombres = state.user['nombres'] as String? ?? '';
                        final apellidos = state.user['apellidos'] as String? ?? '';
                        final vivienda = state.user['vivienda'] as Map<String, dynamic>?;
                        final nombreCompleto = state.user['name'] as String? ?? 'Usuario';
                        final residenceId = vivienda != null
                            ? '${vivienda['manzana']}-${vivienda['villa']}'
                            : '';

                        _inicializarFCM(personaId.toString());

                        if (rol.toLowerCase() == 'admin' ||
                            rol.toLowerCase() == 'administrador') {
                          ctx.read<SecuritySessionBloc>()
                              .add(UnlockSessionRequested());
                          Navigator.pushReplacementNamed(
                            ctx,
                            AppRoutes.adminDashboard,
                            arguments: {
                              'personaId': personaId,
                              'identificacion': identificacion,
                              'residenceId': residenceId,
                              'userName': nombreCompleto,
                            },
                          );
                          return;
                        }

                        final viviendaInfo = ViviendaInfo(
                          viviendaId: vivienda?['vivienda_id'] as int? ??
                              vivienda?['viviendaId'] as int? ??
                              0,
                          manzana: vivienda?['manzana'] as String? ?? '',
                          villa: vivienda?['villa'] as String? ?? '',
                        );

                        final prospecto = ProspectoResidente(
                          personaId: personaId,
                          identificacion: identificacion,
                          nombres: nombres,
                          apellidos: apellidos,
                          tipoRegistro: rol.toLowerCase(),
                          vivienda: viviendaInfo,
                          puedeCrearCuenta: false,
                        );

                        final success = await Navigator.of(ctx).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => FacialVerificationPage(
                              prospecto: prospecto,
                              mode: VerificationMode.unlockApp,
                            ),
                          ),
                        );

                        if (success != true) {
                          _isNavigating = false;
                          if (ctx.mounted) {
                            FocusScope.of(ctx).unfocus();
                            ctx.read<AuthBloc>().add(LogoutRequested());
                            ctx.read<SecuritySessionBloc>()
                                .add(SessionTerminated());
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Verificación facial requerida para acceder.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                          return;
                        }

                        final args = {
                          'personaId': personaId,
                          'identificacion': identificacion,
                          'residenceId': residenceId,
                          'userName': nombreCompleto,
                        };

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

                        Navigator.pushReplacementNamed(
                            ctx, route, arguments: args);
                      } catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Error al navegar al panel: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
                    if (state is AuthLoading) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Verificando sesión...'),
                          ],
                        ),
                      );
                    }
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
                              if (!FormatRules.isValidEmail(v)) {
                                return 'Formato de correo inválido';
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
                              onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        context.read<AuthBloc>().add(
                                              LoginSubmitted(
                                                emailCtrl.text.trim(),
                                                passCtrl.text.trim(),
                                              ),
                                            );
                                      }
                                    },
                              child: const Text('Ingresar'),
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
                              onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacementNamed('/registerOption');
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
