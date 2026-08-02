import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/member/member_bloc.dart';
import '../../application/blocs/member/member_event.dart';
import '../../application/blocs/member/member_state.dart';
import '../../core/validations/format_rules.dart';
import '../widgets/admin_scaffold.dart';

class AdminCreateMemberPage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminCreateMemberPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminCreateMemberPage> createState() => _AdminCreateMemberPageState();
}

class _AdminCreateMemberPageState extends State<AdminCreateMemberPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  late TextEditingController _residenteIdController;
  late TextEditingController _identificacionController;
  late TextEditingController _tipoIdentificacionController;
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
    _identificacionController = TextEditingController();
    _tipoIdentificacionController = TextEditingController(text: 'Cedula');
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
    _identificacionController.dispose();
    _tipoIdentificacionController.dispose();
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

  /// Registrar el miembro usando BLoC
  void _registerMember() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_parentescoController.text.isEmpty) {
      _showErrorSnackBar('Por favor selecciona un parentesco');
      return;
    }

    context.read<MemberBloc>().add(
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
          ),
        );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminScaffold(
      title: 'Registrar Miembro de Familia',
      routeName: '/adminCreateMember',
      showBackButton: true,
      onBackPressed: () {
        Navigator.of(context).pop();
      },
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
        child: BlocListener<MemberBloc, MemberState>(
        listener: (context, state) {
          if (state is MemberCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );

            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/adminFacialEnrollment',
                (route) => route.settings.name == '/adminMembers',
                arguments: {
                  'personaId': state.member['persona_id'] ?? 0,
                  'nombres': _nombresController.text.trim(),
                  'apellidos': _apellidosController.text.trim(),
                  'type': 'member',
                },
              );
            }
          } else if (state is MemberError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: BlocBuilder<MemberBloc, MemberState>(
          builder: (context, state) {
            final isLoading = state is MemberLoading;

            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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

                          // Residente ID (readonly)
                          TextFormField(
                            controller: _residenteIdController,
                            decoration: InputDecoration(
                              hintText: 'Identificación del Residente Titular',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                            readOnly: false,
                          ),
                          const SizedBox(height: 16),

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
                            validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                          ),
                          const SizedBox(height: 12),

                          // Identificación
                          TextFormField(
                            controller: _identificacionController,
                            decoration: InputDecoration(
                              hintText: 'Identificación',
                              prefixIcon: const Icon(Icons.credit_card),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Campo requerido';
                              if (value!.length > 20) return 'Máximo 20 caracteres';
                              if (!FormatRules.isValidId(value)) return 'Cédula inválida (10 dígitos)';
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
                            validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
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
                            validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
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
                                initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                _fechaNacimientoController.text =
                                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              }
                            },
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Campo requerido';
                              final fecha = DateTime.tryParse(value!);
                              if (fecha == null) return 'Formato de fecha inválido';
                              final hoy = DateTime.now();
                              final edad = hoy.year - fecha.year -
                                  (hoy.month < fecha.month || (hoy.month == fecha.month && hoy.day < fecha.day) ? 1 : 0);
                              if (fecha.isAfter(hoy)) return 'La fecha no puede ser futura';
                              if (edad < 18) return 'Debe ser mayor de 18 años';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Parentesco
                          DropdownButtonFormField<String>(
                            value: _parentescoController.text.isEmpty ? null : _parentescoController.text,
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
                                child: Text(value.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _parentescoController.text = newValue ?? '';
                              });
                            },
                            validator: (value) => value == null || value.isEmpty ? 'Selecciona un parentesco' : null,
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
                                    if (_parentescoController.text == 'otro' && (value?.isEmpty ?? true)) {
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
                                if (!FormatRules.isValidEmail(value!)) {
                                  return 'Formato de correo inválido';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Celular (Opcional)
                          TextFormField(
                            controller: _celularController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Celular (Opcional)',
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!FormatRules.isValidPhone(value)) {
                                  return 'Formato inválido: 09XXXXXXXX';
                                }
                              }
                              return null;
                            },
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
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: isLoading ? null : _registerMember,
                                  child: const Text('Registrar Miembro'),
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
    ),
    );
  }
}
