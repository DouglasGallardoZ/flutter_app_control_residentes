import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/validar_prospecto_miembro_usecase.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../../injection.dart';
import 'member_create_registration_page.dart';
import 'member_facial_enrollment_page.dart';
import 'credentials_miembro_page.dart';

class ProspectoMiembroPage extends StatefulWidget {
  const ProspectoMiembroPage({super.key});

  @override
  State<ProspectoMiembroPage> createState() =>
      _ProspectoMiembroPageState();
}

class _ProspectoMiembroPageState
    extends State<ProspectoMiembroPage> {
  final _cedulaCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _cargando = false;
  ProspectoMiembro? _resultado;

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    super.dispose();
  }

  Future<void> _validar() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _cargando = true);

    try {
      final useCase =
          sl<ValidarProspectoMiembroUseCase>();
      final prospecto = await useCase.execute(
          _cedulaCtrl.text.trim());

      if (!prospecto.existe) {
        if (!mounted) return;
        setState(() => _cargando = false);
        _mostrarDialogoNoEncontrado();
        return;
      }

      if (!mounted) return;

      await Future.delayed(
          const Duration(milliseconds: 500));
      if (!mounted) return;

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _cargando = false;
          _resultado = prospecto;
        });
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();

      await Future.delayed(
          const Duration(milliseconds: 400));
      if (!mounted) return;

      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _cargando = false);

        if (msg.contains('no encontrado') ||
            msg.contains('404')) {
          _mostrarDialogoNoEncontrado();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
                content: Text(msg)),
          );
        }
      });
    }
  }

  void _mostrarDialogoNoEncontrado() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
            'Miembro No Registrado'),
        content: const Text(
            'No se encontró un miembro con esta cédula. ¿Deseas registrarte?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(ctx).pop(),
            child:
                const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Future.delayed(
                  const Duration(
                      milliseconds: 300),
                  () {
                if (!mounted) return;
                WidgetsBinding.instance
                    .addPostFrameCallback(
                        (_) {
                  if (!mounted) return;
                  Navigator.of(context)
                      .pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          MemberCreateRegistrationPage(
                        identificacion:
                            _cedulaCtrl
                                .text
                                .trim(),
                        requiereAutorizacion:
                            true,
                      ),
                    ),
                  );
                });
              });
            },
            child:
                const Text('Registrarme'),
          ),
        ],
      ),
    );
  }

  void _continuar() {
    final prospecto = _resultado!;
    final necesitaEnrolamiento =
        prospecto.tieneFacialEnrolado !=
            true;

    if (necesitaEnrolamiento) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.face,
              size: 48,
              color: Colors.blue),
          title: const Text(
              'Registro Facial Pendiente'),
          content: const Text(
              'Tu cuenta fue aprobada pero aún no completaste tu registro facial.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Future.delayed(
                    const Duration(
                        milliseconds: 400),
                    () {
                  if (!mounted) return;
                  WidgetsBinding.instance
                      .addPostFrameCallback(
                          (_) {
                    if (!mounted) return;
                    Navigator.of(context)
                        .pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            MemberFacialEnrollmentPage(
                          personaId: prospecto
                                  .personaId ??
                              0,
                          nombres: prospecto
                                  .nombres ??
                              '',
                          apellidos: prospecto
                                  .apellidos ??
                              '',
                          type: 'member',
                          origen:
                              'prospecto_miembro',
                          prospectoCompleto:
                              prospecto,
                        ),
                      ),
                    );
                  });
                });
              },
              child: const Text(
                  'Continuar'),
            ),
          ],
        ),
      );
    } else {
      Future.delayed(
          const Duration(milliseconds: 400),
          () {
        if (!mounted) return;
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context)
              .pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  CredentialsMiembroPage(
                personaId:
                    prospecto.personaId ?? 0,
                nombres: prospecto.nombres ??
                    '',
                apellidos: prospecto
                        .apellidos ??
                    '',
              ),
            ),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight =
        Theme.of(context).brightness ==
            Brightness.light;

    if (_resultado != null) {
      return _buildResultado(_resultado!);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLight
                ? const [
                    Color(0xFFFFFFFF),
                    Color(0xFFDCDBE5)
                  ]
                : const [
                    Color(0xFF1A1A2E),
                    Color(0xFF2D1B3D)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 420),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(24),
              child: Card(
                elevation: 6,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                          24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [
                        const Icon(
                          Icons
                              .badge_outlined,
                          size: 48,
                          color: Color(
                              0xFF04345C),
                        ),
                        const SizedBox(
                            height: 16),
                        Text(
                          'Validar Identidad',
                          style: Theme.of(
                                  context)
                              .textTheme
                              .headlineMedium,
                        ),
                        const SizedBox(
                            height: 8),
                        const Text(
                          'Ingresa tu número de cédula',
                        ),
                        const SizedBox(
                            height: 24),
                        TextFormField(
                          controller:
                              _cedulaCtrl,
                          keyboardType:
                              TextInputType
                                  .number,
                          decoration:
                              InputDecoration(
                            hintText:
                                'Cédula',
                            prefixIcon:
                                const Icon(
                                    Icons
                                        .credit_card),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                          ),
                          validator: (v) =>
                              (v == null ||
                                      v.trim()
                                              .length <
                                          10)
                                  ? 'Ingresa una cédula válida'
                                  : null,
                        ),
                        const SizedBox(
                            height: 24),
                        SizedBox(
                          width:
                              double.infinity,
                          height: 48,
                          child:
                              ElevatedButton(
                            onPressed: _cargando
                                ? null
                                : _validar,
                            style: ElevatedButton
                                .styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xFF04345C),
                              foregroundColor:
                                  Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            12),
                              ),
                            ),
                            child: _cargando
                                ? const SizedBox(
                                    width:
                                        24,
                                    height:
                                        24,
                                    child: CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color: Colors
                                          .white,
                                    ),
                                  )
                                : Text(
                                    'Validar',
                                    style: Theme.of(
                                            context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors
                                              .white,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                  ),
                          ),
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
    );
  }

  Widget _buildResultado(
      ProspectoMiembro p) {
    final isLight =
        Theme.of(context).brightness ==
            Brightness.light;
    final necesitaEnrolamiento =
        p.tieneFacialEnrolado != true;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLight
                ? const [
                    Color(0xFFFFFFFF),
                    Color(0xFFDCDBE5)
                  ]
                : const [
                    Color(0xFF1A1A2E),
                    Color(0xFF2D1B3D)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 420),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(24),
              child: Card(
                elevation: 6,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                          24),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                          Icons.check_circle,
                          size: 64,
                          color: Color(
                              0xFF04345C)),
                      const SizedBox(
                          height: 16),
                      Text(
                        'Identidad Verificada',
                        style: Theme.of(
                                context)
                            .textTheme
                            .headlineMedium,
                      ),
                      const SizedBox(
                          height: 16),
                      _row(
                        'Nombre',
                        '${p.nombres ?? ""} ${p.apellidos ?? ""}',
                      ),
                      const SizedBox(
                          height: 8),
                      _row(
                        'Cédula',
                        p.identificacion ??
                            '',
                      ),
                      const SizedBox(
                          height: 8),
                      _row(
                        'Parentesco',
                        p.parentesco ?? '',
                      ),
                      if (p.vivienda !=
                          null) ...[
                        const SizedBox(
                            height: 8),
                        _row(
                          'Dirección',
                          'Mz ${p.vivienda!.manzana}, Villa ${p.vivienda!.villa}',
                        ),
                      ],
                      const SizedBox(
                          height: 24),
                      Text(
                        necesitaEnrolamiento
                            ? 'Debes completar tu registro facial.'
                            : 'Presiona continuar.',
                        textAlign:
                            TextAlign.center,
                      ),
                      const SizedBox(
                          height: 24),
                      SizedBox(
                        width:
                            double.infinity,
                        height: 48,
                        child:
                            ElevatedButton(
                          onPressed:
                              _continuar,
                          style: ElevatedButton
                              .styleFrom(
                            backgroundColor:
                                const Color(
                                    0xFF04345C),
                            foregroundColor:
                                Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                            ),
                          ),
                          child: Text(
                            'Continuar',
                            style: Theme.of(
                                    context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors
                                      .white,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
      String label, String value) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text('$label:',
              style: const TextStyle(
                  fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w500)),
        ),
      ],
    );
  }
}
