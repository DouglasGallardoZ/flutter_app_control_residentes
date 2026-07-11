import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../application/blocs/member/member_bloc.dart';
import '../../application/blocs/member/member_event.dart';
import '../../application/blocs/member/member_state.dart';
import '../../application/blocs/facial_enrollment/facial_enrollment_bloc.dart';
import '../../domain/usecases/solicitar_registro_miembro_usecase.dart';
import 'miembros/esperar_autorizacion_page.dart';
import 'member_facial_enrollment_page.dart';

class MemberCreateRegistrationPage extends StatefulWidget {
  final String identificacion;
  final bool requiereAutorizacion;

  const MemberCreateRegistrationPage({
    super.key,
    required this.identificacion,
    this.requiereAutorizacion = false,
  });

  @override
  State<MemberCreateRegistrationPage> createState() =>
      _MemberCreateRegistrationPageState();
}

class _MemberCreateRegistrationPageState
    extends State<MemberCreateRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controladores de texto
  late TextEditingController _residenteIdController;
  late TextEditingController _tipoIdentificacionController;
  late TextEditingController _identificacionController;
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _nacionalidadController;
  late TextEditingController _correoController;
  late TextEditingController _celularController;
  late TextEditingController _direccionAlternativaController;
  late TextEditingController _manzanaController;
  late TextEditingController _villaController;
  late TextEditingController _parentescoController;
  late TextEditingController _parentescoOtroDescController;

  // Opciones de parentesco
  final List<String> _parentescoOptions = [
    'padre',
    'madre',
    'esposo',
    'esposa',
    'hijo',
    'hija',
    'otro',
  ];

  @override
  void initState() {
    super.initState();

    _residenteIdController = TextEditingController();
    _tipoIdentificacionController = TextEditingController(text: 'Cedula');
    _identificacionController = TextEditingController(text: widget.identificacion);
    _nombresController = TextEditingController();
    _apellidosController = TextEditingController();
    _fechaNacimientoController = TextEditingController();
    _nacionalidadController = TextEditingController(text: 'Ecuador');
    _correoController = TextEditingController();
    _celularController = TextEditingController();
    _direccionAlternativaController = TextEditingController();
    _manzanaController = TextEditingController();
    _villaController = TextEditingController();
    _parentescoController = TextEditingController();
    _parentescoOtroDescController = TextEditingController();
  }

  @override
  void dispose() {
    _residenteIdController.dispose();
    _tipoIdentificacionController.dispose();
    _identificacionController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _fechaNacimientoController.dispose();
    _nacionalidadController.dispose();
    _correoController.dispose();
    _celularController.dispose();
    _direccionAlternativaController.dispose();
    _manzanaController.dispose();
    _villaController.dispose();
    _parentescoController.dispose();
    _parentescoOtroDescController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_parentescoController.text.isEmpty) {
      _showErrorSnackBar('Por favor selecciona un parentesco');
      return;
    }

    if (!mounted) {
      return;
    }

    // FLUJO MIEMBRO: auto-registro con autorización del titular
    if (widget.requiereAutorizacion) {
      setState(() => _isSubmitting = true);

      try {
        final useCase = GetIt.instance<SolicitarRegistroMiembroUseCase>();
        final notificacionId = await useCase.execute(
          identificacionResidente: _residenteIdController.text.trim(),
          manzana: _manzanaController.text.trim(),
          villa: _villaController.text.trim(),
          identificacion: _identificacionController.text.trim(),
          nombres: _nombresController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          fechaNacimiento: _fechaNacimientoController.text.trim(),
          parentesco: _parentescoController.text.trim(),
          parentescoOtroDesc: _parentescoOtroDescController.text.trim().isEmpty
              ? null
              : _parentescoOtroDescController.text.trim(),
          correo: _correoController.text.trim().isEmpty
              ? null
              : _correoController.text.trim(),
          celular: _celularController.text.trim().isEmpty
              ? null
              : _celularController.text.trim(),
        );

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => EsperarAutorizacionPage(
              identificacion: _identificacionController.text.trim(),
              nombres: _nombresController.text.trim(),
              apellidos: _apellidosController.text.trim(),
              parentesco: _parentescoController.text.trim(),
              manzana: _manzanaController.text.trim(),
              villa: _villaController.text.trim(),
              fechaNacimiento: _fechaNacimientoController.text.trim(),
              correo: _correoController.text.trim().isEmpty
                  ? null
                  : _correoController.text.trim(),
              celular: _celularController.text.trim().isEmpty
                  ? null
                  : _celularController.text.trim(),
              identificacionResidente: _residenteIdController.text.trim(),
              notificacionId: notificacionId,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        final mensaje = e.toString().replaceAll('Exception: ', '');

        if (mensaje.contains('409') ||
            mensaje.contains('solicitud pendiente') ||
            mensaje.contains('pendiente')) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => EsperarAutorizacionPage(
                identificacion: _identificacionController.text.trim(),
                nombres: _nombresController.text.trim(),
                apellidos: _apellidosController.text.trim(),
                parentesco: _parentescoController.text.trim(),
                manzana: _manzanaController.text.trim(),
                villa: _villaController.text.trim(),
                fechaNacimiento: _fechaNacimientoController.text.trim(),
                correo: _correoController.text.trim().isEmpty
                    ? null
                    : _correoController.text.trim(),
                celular: _celularController.text.trim().isEmpty
                    ? null
                    : _celularController.text.trim(),
                identificacionResidente: _residenteIdController.text.trim(),
                notificacionId: 0,
              ),
            ),
          );
          return;
        }

        _showErrorSnackBar(mensaje);
      }

      return;
    }

    // FLUJO ADMIN: crear persona directamente
    try {
      final memberBloc = context.read<MemberBloc>();

      memberBloc.add(
        CreateMemberEvent(
          residenteId: _residenteIdController.text.trim(),
          identificacion: _identificacionController.text.trim(),
          tipoIdentificacion: _tipoIdentificacionController.text.trim(),
          nombres: _nombresController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          fechaNacimiento: _fechaNacimientoController.text.trim(),
          correo: _correoController.text.trim().isEmpty
              ? null
              : _correoController.text.trim(),
          celular: _celularController.text.trim().isEmpty
              ? null
              : _celularController.text.trim(),
          manzana: _manzanaController.text.trim(),
          villa: _villaController.text.trim(),
          parentesco: _parentescoController.text.trim(),
          nacionalidad: _nacionalidadController.text.trim().isEmpty
              ? null
              : _nacionalidadController.text.trim(),
          direccionAlternativa: _direccionAlternativaController.text.trim().isEmpty
              ? null
              : _direccionAlternativaController.text.trim(),
          parentescoOtroDesc: _parentescoOtroDescController.text.trim().isEmpty
              ? null
              : _parentescoOtroDescController.text.trim(),
          usuarioCreado: 'flutter_app',
        ),
      );
    } catch (e) {
      debugPrint('Error en _submitForm: $e');
      debugPrint('Stack trace: ${StackTrace.current}');

      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Datos de Miembro'),
        centerTitle: true,
      ),
      body: BlocListener<MemberBloc, MemberState>(
        listener: (context, state) {
          // FLUJO REPLICADO DE admin_create_member_page.dart línea 154-179:
          // Escuchar estados del MemberBloc:
          // - MemberCreated: El API creó exitosamente el miembro
          // - MemberError: Error en la creación
          
          if (state is MemberCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.fixed,
                duration: const Duration(seconds: 2),
              ),
            );

            if (mounted) {
              // FLUJO ADMIN: crear persona → ir directo a enrolamiento facial
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => BlocProvider<FacialEnrollmentBloc>(
                    create: (_) => GetIt.instance<FacialEnrollmentBloc>(),
                    child: MemberFacialEnrollmentPage(
                      personaId: state.member['persona_id'] ?? 0,
                      nombres: _nombresController.text.trim(),
                      apellidos: _apellidosController.text.trim(),
                      type: 'member',
                    ),
                  ),
                ),
              );
            }
          } else if (state is MemberError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: BlocBuilder<MemberBloc, MemberState>(
          builder: (context, state) {
            // BlocBuilder para mostrar estado de carga y deshabilitar botones
            // mientras se procesa la creación del miembro (admin_create_member_page.dart línea 180)
            bool isLoading = state is MemberLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Residente Titular',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Residente ID (cédula del usuario que está registrando)
              TextFormField(
                // initialValue: widget.identificacion,
                // enabled: true,
                controller: _residenteIdController,
                decoration: InputDecoration(
                  hintText: 'Identificación del Residente Titular',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),

              Text(
                'Información del Miembro',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Tipo de Identificación
              DropdownButtonFormField<String>(
                value: _tipoIdentificacionController.text,
                decoration: InputDecoration(
                  hintText: 'Tipo de Identificación',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Cedula', 'Pasaporte', 'Otro'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoIdentificacionController.text = newValue ?? '';
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              // Identificación (readonly)
              TextFormField(
                controller: _identificacionController,
                decoration: InputDecoration(
                  hintText: 'Identificación',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  if (value!.length > 20) return 'Máximo 20 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Nombres
              TextFormField(
                controller: _nombresController,
                decoration: InputDecoration(
                  hintText: 'Nombres',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              // Apellidos
              TextFormField(
                controller: _apellidosController,
                decoration: InputDecoration(
                  hintText: 'Apellidos',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              // Fecha de Nacimiento
              TextFormField(
                controller: _fechaNacimientoController,
                decoration: InputDecoration(
                  hintText: 'Fecha de Nacimiento (YYYY-MM-DD)',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().subtract(const Duration(days: 365 * 18)),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _fechaNacimientoController.text =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              // Parentesco
              DropdownButtonFormField<String>(
                value: _parentescoController.text.isEmpty
                    ? null
                    : _parentescoController.text,
                decoration: InputDecoration(
                  hintText: 'Parentesco',
                  prefixIcon: const Icon(Icons.family_restroom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _parentescoOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _parentescoController.text = newValue ?? '';
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Selecciona un parentesco'
                        : null,
              ),
              const SizedBox(height: 12),

              // Descripción de Otro Parentesco
              if (_parentescoController.text == 'otro')
                Column(
                  children: [
                    TextFormField(
                      controller: _parentescoOtroDescController,
                      decoration: InputDecoration(
                        hintText: 'Especifica el parentesco',
                        prefixIcon: const Icon(Icons.note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (_parentescoController.text == 'otro' &&
                            (value?.isEmpty ?? true)) {
                          return 'Por favor especifica el parentesco';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

              // Nacionalidad
              TextFormField(
                controller: _nacionalidadController,
                decoration: InputDecoration(
                  hintText: 'Nacionalidad',
                  prefixIcon: const Icon(Icons.public),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Correo (Opcional)
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(
                  hintText: 'Correo Electrónico (Opcional)',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value?.isNotEmpty ?? false) {
                    final emailRegex =
                        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                    if (!emailRegex.hasMatch(value!)) {
                      return 'Correo inválido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Celular (Opcional)
              TextFormField(
                controller: _celularController,
                decoration: InputDecoration(
                  hintText: 'Celular (Opcional)',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dirección Alternativa (Opcional)
              TextFormField(
                controller: _direccionAlternativaController,
                decoration: InputDecoration(
                  hintText: 'Dirección Alternativa (Opcional)',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Ubicación',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Manzana y Villa (lado a lado)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _manzanaController,
                      decoration: InputDecoration(
                        hintText: 'Manzana',
                        prefixIcon: const Icon(Icons.home),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Manzana requerida';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _villaController,
                      decoration: InputDecoration(
                        hintText: 'Villa',
                        prefixIcon: const Icon(Icons.apartment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Villa requerida';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Info de nota
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Después de registrar, se abrirá la pantalla de registro facial.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading ? null : () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isLoading || _isSubmitting ? null : _submitForm,
                      child: isLoading || _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Registrar Miembro'),
                    ),
                  ),
                ],
              ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
  }
}
