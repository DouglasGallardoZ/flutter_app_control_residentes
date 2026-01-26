import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/prospecto_validation/prospecto_validation_bloc.dart';
import '../../application/blocs/prospecto_validation/prospecto_validation_event.dart';
import '../../application/blocs/prospecto_validation/prospecto_validation_state.dart';

class ProspectoResidentePage extends StatefulWidget {
  const ProspectoResidentePage({super.key});

  @override
  State<ProspectoResidentePage> createState() => _ProspectoResidentePageState();
}

class _ProspectoResidentePageState extends State<ProspectoResidentePage> {
  final cedulaCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    cedulaCtrl.dispose();
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
                child: BlocListener<ProspectoValidationBloc, ProspectoValidationState>(
                  listener: (context, state) {
                    if (state is ProspectoResidenteValidado) {
                      // Navegar a la siguiente página de validación facial
                      Navigator.of(context).pushNamed(
                        '/facialVerification',
                        arguments: state.prospecto,
                      );
                    } else if (state is ProspectoValidationError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<ProspectoValidationBloc, ProspectoValidationState>(
                    builder: (context, state) {
                      final loading = state is ProspectoValidationLoading;
                      return Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.badge,
                              size: 48,
                              color: Color(0xFF04345C),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Validar Identidad',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ingrese su número de cédula para verificar sus datos',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: cedulaCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Número de Cédula',
                                hintText: 'Ej: 1234567890',
                                prefixIcon: Icon(Icons.credit_card),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Ingrese su número de cédula';
                                }
                                if (v.length < 10) {
                                  return 'La cédula debe tener al menos 10 dígitos';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: loading
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          context
                                              .read<ProspectoValidationBloc>()
                                              .add(
                                                ValidarProspectoResidente(
                                                  cedulaCtrl.text,
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
                                    : const Text('Validar'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: loading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Volver'),
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
      ),
    );
  }
}
