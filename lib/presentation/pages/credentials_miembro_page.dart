import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../../application/blocs/registro_residente/registro_residente_bloc.dart';
import '../../application/blocs/registro_residente/registro_residente_event.dart';
import '../../application/blocs/registro_residente/registro_residente_state.dart';
import '../../application/blocs/auth/auth_bloc.dart';
import '../../application/blocs/auth/auth_event.dart';
import '../../application/blocs/auth/auth_state.dart';

class CredentialsMiembroPage extends StatefulWidget {
  final ProspectoResidente? prospecto;
  final String? imagePath;
  final int? personaId;
  final String? nombres;
  final String? apellidos;

  const CredentialsMiembroPage({
    super.key,
    this.prospecto,
    this.imagePath,
    this.personaId,
    this.nombres,
    this.apellidos,
  });

  @override
  State<CredentialsMiembroPage> createState() =>
      _CredentialsMiembroPageState();
}

class _CredentialsMiembroPageState extends State<CredentialsMiembroPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool showPassword = false;
  bool isCreating = false;

  late final bool _isEmailReadOnly;

  @override
  void initState() {
    super.initState();
    final correo = widget.prospecto?.correo;
    if (correo != null && correo.isNotEmpty) {
      emailCtrl.text = correo;
      _isEmailReadOnly = true;
    } else {
      _isEmailReadOnly = false;
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  int get _personaId => widget.prospecto?.personaId ?? widget.personaId ?? 0;
  String get _nombres => widget.prospecto?.nombres ?? widget.nombres ?? '';
  String get _apellidos =>
      widget.prospecto?.apellidos ?? widget.apellidos ?? '';
  String get _identificacion => widget.prospecto?.identificacion ?? '';

  void _crearCuenta() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() => isCreating = true);
    context.read<AuthBloc>().add(
      CreateUserSubmitted(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RegistroResidenteBloc, RegistroResidenteState>(
          listener: (context, state) {
            if (state is CuentaCreada) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Cuenta creada exitosamente. Inicia sesión para continuar.'),
                  backgroundColor: Colors.green,
                ),
              );

              context.read<AuthBloc>().add(LogoutRequested());

              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            } else if (state is RegistroResidenteError) {
              setState(() => isCreating = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is UserCreated) {
              if (mounted) {
                context.read<RegistroResidenteBloc>().add(
                  CrearCuentaMiembro(
                    personaId: _personaId,
                    firebaseUid: state.uid,
                    email: state.email,
                  ),
                );
              }
            } else if (state is AuthFailure) {
              setState(() => isCreating = false);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
      child: Scaffold(
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
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 48,
                            color: Color(0xFF04345C),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Crear Credenciales',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingrese un correo y contraseña para su cuenta',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: emailCtrl,
                            enabled: !_isEmailReadOnly,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo Electrónico',
                              hintText: 'ejemplo@correo.com',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingrese un correo';
                              }
                              if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v)) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: passwordCtrl,
                            obscureText: !showPassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              hintText: 'Al menos 6 caracteres',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() => showPassword = !showPassword);
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingrese una contraseña';
                              }
                              if (v.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: confirmPasswordCtrl,
                            obscureText: !showPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmar Contraseña',
                              hintText: 'Repita la contraseña',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() => showPassword = !showPassword);
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirme la contraseña';
                              }
                              if (v != passwordCtrl.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isCreating ? null : _crearCuenta,
                              child: isCreating
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Crear Cuenta'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: isCreating
                                ? null
                                : () {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false,
                                    );
                                  },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Volver'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
