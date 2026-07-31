import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/validar_prospecto_residente_usecase.dart';
import '../../core/validations/format_rules.dart';
import '../../injection.dart';

class ProspectoResidentePage extends StatefulWidget {
  const ProspectoResidentePage({super.key});

  @override
  State<ProspectoResidentePage> createState() =>
      _ProspectoResidentePageState();
}

class _ProspectoResidentePageState
    extends State<ProspectoResidentePage> {
  final _cedulaCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _cargando = false;
  bool _navegando = false;

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    super.dispose();
  }

  Future<void> _validar() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (_navegando) return;

    FocusScope.of(context).unfocus();
    setState(() => _cargando = true);

    try {
      final useCase = sl<ValidarProspectoResidenteUseCase>();
      final prospecto =
          await useCase.execute(_cedulaCtrl.text.trim());

      if (!mounted || _navegando) return;
      _navegando = true;

      await Navigator.of(context).pushNamed(
        '/facialVerification',
        arguments: prospecto,
      );

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
        _navegando = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight =
        Theme.of(context).brightness == Brightness.light;

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
            constraints:
                const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 48,
                          color: Color(0xFF04345C),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Validar Identidad',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ingresa tu número de cédula',
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _cedulaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Cédula',
                            prefixIcon:
                                const Icon(Icons.credit_card),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => (v == null ||
                                  v.trim().isEmpty)
                              ? 'Ingresa una cédula'
                              : (!FormatRules.isValidId(
                                      v.trim())
                                  ? 'Cédula inválida (10 dígitos)'
                                  : null),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                                _cargando ? null : _validar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF04345C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            child: _cargando
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Validar',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
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
}
