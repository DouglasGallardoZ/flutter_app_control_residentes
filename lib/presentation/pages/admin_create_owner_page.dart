import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/owner/owner_bloc.dart';
import '../../application/blocs/owner/owner_event.dart';
import '../../application/blocs/owner/owner_state.dart';
import '../../core/validations/format_rules.dart';
import '../widgets/admin_scaffold.dart';

class AdminCreateOwnerPage extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminCreateOwnerPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminCreateOwnerPage> createState() =>
      _AdminCreateOwnerPageState();
}

class _AdminCreateOwnerPageState extends State<AdminCreateOwnerPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
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

  @override
  void initState() {
    super.initState();
    
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
  }

  @override
  void dispose() {
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
    super.dispose();
  }

  /// Registrar el propietario usando BLoC
  void _registerOwner() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<OwnerBloc>().add(
          CreateOwnerEvent(
            identificacion: _identificacionController.text.trim(),
            tipoIdentificacion: _tipoIdentificacionController.text.trim(),
            nombres: _nombresController.text.trim(),
            apellidos: _apellidosController.text.trim(),
            fechaNacimiento: _fechaNacimientoController.text.trim(),
            correo: _correoController.text.trim(),
            celular: _celularController.text.trim(),
            manzana: _manzanaController.text.trim(),
            villa: _villaController.text.trim(),
            nacionalidad: _nacionalidadController.text.trim().isEmpty
                ? null
                : _nacionalidadController.text.trim(),
            direccionAlternativa: _direccionAlternativaController.text.trim().isEmpty
                ? null
                : _direccionAlternativaController.text.trim(),
            usuarioCreado: 'admin_${widget.personaId}',
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
      title: 'Registrar Propietario',
      routeName: '/adminCreateOwner',
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
        child: BlocListener<OwnerBloc, OwnerState>(
        listener: (context, state) {
          if (state is OwnerCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );

            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/adminFacialEnrollment',
                (route) => route.settings.name == '/adminOwners',
                arguments: {
                  'personaId': state.owner['persona_id'] ?? 0,
                  'nombres': _nombresController.text.trim(),
                  'apellidos': _apellidosController.text.trim(),
                  'type': 'owner',
                },
              );
            }
          } else if (state is OwnerError) {
            _showErrorSnackBar(state.message);
          }
        },
        child: BlocBuilder<OwnerBloc, OwnerState>(
          builder: (context, state) {
            final isLoading = state is OwnerLoading;

            return isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Propietario',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
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
                                items: ['Cedula', 'RUC', 'Pasaporte', 'Otro']
                                    .map((tipo) => DropdownMenuItem(
                                          value: tipo,
                                          child: Text(tipo),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _tipoIdentificacionController.text = value ?? 'Cedula';
                                  });
                                },
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'El tipo de identificación es requerido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Identificación
                              TextFormField(
                                controller: _identificacionController,
                                decoration: InputDecoration(
                                  hintText: 'Identificación',
                                  prefixIcon: const Icon(Icons.card_giftcard),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'La identificación es requerida';
                                  }
                                  if (!FormatRules.isValidId(value!)) {
                                    return 'Cédula inválida (10 dígitos)';
                                  }
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
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Los nombres son requeridos';
                                  }
                                  return null;
                                },
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
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Los apellidos son requeridos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Fecha de Nacimiento
                              TextFormField(
                                controller: _fechaNacimientoController,
                                decoration: InputDecoration(
                                  hintText: 'Fecha de nacimiento (YYYY-MM-DD)',
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
                                  if (value?.isEmpty ?? true) {
                                    return 'La fecha de nacimiento es requerida';
                                  }
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

                              // Correo Electrónico
                              TextFormField(
                                controller: _correoController,
                                decoration: InputDecoration(
                                  hintText: 'Correo electrónico',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'El correo es requerido';
                                  }
                                  if (!FormatRules.isValidEmail(value!)) {
                                    return 'Formato de correo inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Celular
                              TextFormField(
                                controller: _celularController,
                                decoration: InputDecoration(
                                  hintText: 'Celular',
                                  prefixIcon: const Icon(Icons.phone),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'El celular es requerido';
                                  }
                                  if (!FormatRules.isValidPhone(value!)) {
                                    return 'Formato inválido: 09XXXXXXXX';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Ubicación - Sección
                              Text(
                                'Ubicación (Vivienda)',
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
                              const SizedBox(height: 12),

                              // Dirección Alternativa
                              TextFormField(
                                controller: _direccionAlternativaController,
                                decoration: InputDecoration(
                                  hintText: 'Dirección Alternativa (opcional)',
                                  prefixIcon: const Icon(Icons.location_on),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                maxLines: 2,
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
                                      onPressed: isLoading ? null : _registerOwner,
                                      child: const Text('Registrar Propietario'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    ),
    );
  }
}
