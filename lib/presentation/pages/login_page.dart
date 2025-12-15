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
  final formKey = GlobalKey<FormState>();

  String _digitsCounter(String value) => '${value.replaceAll(RegExp(r'[^0-9]'), '').length}/10 dígitos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradiente azul-morado como en Figma
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (ctx, state) {
                    if (state is AuthSuccess) {
                      final role = state.user['role'];
                      final userId = (state.user['id'] ?? state.user['uid']) as String;

                      // Reemplaza la pila para que no haya back al dashboard
                      if (role == 'admin') {
                        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard, arguments: userId);
                      } else if (role == 'resident') {
                        Navigator.pushReplacementNamed(context, AppRoutes.residentDashboard, arguments: userId);
                      } else {
                        Navigator.pushReplacementNamed(context, AppRoutes.familyDashboard, arguments: userId);
                      }
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (ctx, state) {
                    final loading = state is AuthLoading;
                    return Form(
                      key: formKey,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.shield, size: 48, color: Color(0xFF3B82F6)),
                        const SizedBox(height: 8),
                        Text('Bienvenido', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        const Text('Ingrese sus credenciales para continuar'),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: idCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Identificación',
                            hintText: 'Ingrese 10 dígitos',
                            helperText: _digitsCounter(idCtrl.text),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            final digits = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                            if (digits.length != 10) return 'Ingrese 10 dígitos';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passCtrl,
                          decoration: const InputDecoration(labelText: 'Contraseña', hintText: 'Ingrese su contraseña'),
                          obscureText: true,
                          validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: loading
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(LoginSubmitted(idCtrl.text.trim(), passCtrl.text.trim()));
                                    }
                                  },
                            child: loading ? const CircularProgressIndicator() : const Text('Ingresar'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                            Text('Credenciales de prueba:', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 6),
                            Text('Admin: 1234567890 / admin123'),
                            Text('Residente: 0987654321 / resident123'),
                            Text('Familiar: 1122334455 / family123'),
                          ]),
                        ),
                      ]),
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
