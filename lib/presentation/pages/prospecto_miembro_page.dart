import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../application/blocs/prospecto_validation/prospecto_validation_bloc.dart';
import '../../application/blocs/prospecto_validation/prospecto_validation_event.dart';
import '../../application/blocs/prospecto_validation/prospecto_validation_state.dart';
import '../../application/blocs/member/member_bloc.dart';
import '../../application/blocs/member/member_state.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../routes/app_routes.dart';
import 'member_create_registration_page.dart';

class ProspectoMiembroPage extends StatefulWidget {
  const ProspectoMiembroPage({super.key});

  @override
  State<ProspectoMiembroPage> createState() => _ProspectoMiembroPageState();
}

class _ProspectoMiembroPageState extends State<ProspectoMiembroPage> {
  final cedulaCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    cedulaCtrl.dispose();
    super.dispose();
  }

  void _showCreateMemberDialog(String cedula) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Miembro No Registrado'),
        content: const Text(
          'No encontramos tu registro como miembro. ¿Deseas completar tu perfil y registrarte?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              
              // Navegar a memberCreateRegistration envuelto con MemberBloc
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider<MemberBloc>(
                    create: (_) => GetIt.instance<MemberBloc>(),
                    child: MemberCreateRegistrationPage(
                      identificacion: cedula,
                    ),
                  ),
                ),
              );
            },
            child: const Text('Registrarme'),
          ),
        ],
      ),
    );
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
                    if (state is ProspectoMiembroValidado) {
                      // Si el miembro ya está registrado, convertir a ProspectoResidente para facial verification
                      final miembro = state.prospecto;
                      final prospecto = ProspectoResidente(
                        personaId: miembro.personaId ?? 0,
                        identificacion: miembro.identificacion ?? '',
                        nombres: miembro.nombres ?? '',
                        apellidos: miembro.apellidos ?? '',
                        correo: miembro.correo,
                        celular: miembro.celular,
                        tipoRegistro: 'miembro',
                        vivienda: miembro.vivienda ?? ViviendaInfo(
                          viviendaId: 0,
                          manzana: '',
                          villa: '',
                        ),
                        puedeCrearCuenta: miembro.puedeCrearCuenta ?? true,
                      );
                      // Ir directamente a validación facial
                      Navigator.of(context).pushNamed(
                        AppRoutes.facialVerification,
                        arguments: prospecto,
                      );
                    } else if (state is ProspectoValidationError) {
                      // Distinguir entre "miembro no encontrado" y otros errores
                      if (state.message.contains('no encontrado')) {
                        // Si no está registrado, mostrar opción de crear perfil
                        _showCreateMemberDialog(cedulaCtrl.text);
                      } else {
                        // Mostrar error genérico
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error en Validación'),
                            content: Text(state.message),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
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
                                                ValidarProspectoMiembro(
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
