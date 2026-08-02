import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/owner/owner_bloc.dart';
import '../../application/blocs/owner/owner_event.dart';
import '../../application/blocs/owner/owner_state.dart';
import '../../domain/entities/owner_entity.dart';
import '../../core/validations/format_rules.dart';
import '../widgets/admin_scaffold.dart';

class CreateSpousePage extends StatefulWidget {
  final int personaId;
  final String identificacion;
  final OwnerEntity owner;

  const CreateSpousePage({
    super.key,
    required this.personaId,
    required this.identificacion,
    required this.owner,
  });

  @override
  State<CreateSpousePage> createState() =>
      _CreateSpousePageState();
}

class _CreateSpousePageState
    extends State<CreateSpousePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController
      _tipoIdentificacionController;
  late TextEditingController
      _identificacionController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController
      _fechaNacimientoController;
  late TextEditingController
      _nacionalidadController;
  late TextEditingController _correoController;
  late TextEditingController _celularController;
  late TextEditingController
      _direccionAlternativaController;

  @override
  void initState() {
    super.initState();
    _tipoIdentificacionController =
        TextEditingController(
            text: 'Cedula');
    _identificacionController =
        TextEditingController();
    _nombreController =
        TextEditingController();
    _apellidoController =
        TextEditingController();
    _fechaNacimientoController =
        TextEditingController();
    _nacionalidadController =
        TextEditingController(
            text: 'Ecuador');
    _correoController =
        TextEditingController();
    _celularController =
        TextEditingController();
    _direccionAlternativaController =
        TextEditingController();
  }

  @override
  void dispose() {
    _tipoIdentificacionController
        .dispose();
    _identificacionController
        .dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _fechaNacimientoController
        .dispose();
    _nacionalidadController
        .dispose();
    _correoController.dispose();
    _celularController.dispose();
    _direccionAlternativaController
        .dispose();
    super.dispose();
  }

  void _createSpouse() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    context.read<OwnerBloc>().add(
          CreateSpouseEvent(
            ownerId: widget.owner.id,
            tipoIdentificacion:
                _tipoIdentificacionController
                    .text,
            identificacion:
                _identificacionController
                    .text
                    .trim(),
            nombre: _nombreController
                .text
                .trim(),
            apellido: _apellidoController
                .text
                .trim(),
            fechaNacimiento:
                _fechaNacimientoController
                    .text,
            nacionalidad:
                _nacionalidadController
                    .text,
            correo: _correoController
                .text
                .trim(),
            celular: _celularController
                .text
                .trim(),
            direccionAlternativa:
                _direccionAlternativaController
                        .text
                        .isEmpty
                    ? null
                    : _direccionAlternativaController
                        .text
                        .trim(),
          ),
        );
  }

  void _showErrorSnackBar(
      String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AdminScaffold(
      title: 'Registrar Cónyuge',
      routeName: '/createSpouse',
      showBackButton: true,
      onBackPressed: () {
        Navigator.of(context).pop();
      },
      body: BlocListener<OwnerBloc,
          OwnerState>(
        listener: (context, state) {
          if (state is SpouseCreated) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(
                '/adminFacialEnrollment',
                arguments: {
                  'personaId': state.spouse.personaId,
                  'nombres': state.spouse.nombre,
                  'apellidos': state.spouse.apellido,
                  'type': 'spouse',
                },
              );
            }
          } else if (state
              is SpouseError) {
            _showErrorSnackBar(
                state.message);
          }
        },
        child: BlocBuilder<OwnerBloc,
            OwnerState>(
          builder: (context, state) {
            final isLoading =
                state is SpouseCreating;

            return isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator())
                : SingleChildScrollView(
                    padding:
                        const EdgeInsets
                            .all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Información del Propietario',
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .w600),
                        ),
                        const SizedBox(
                            height: 12),
                        Container(
                          padding:
                              const EdgeInsets
                                  .all(16),
                          decoration:
                              BoxDecoration(
                            color: theme
                                .colorScheme
                                .primary
                                .withOpacity(
                                    0.05),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        12),
                            border: Border
                                .all(
                              color: theme
                                  .colorScheme
                                  .primary
                                  .withOpacity(
                                      0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Colors
                                            .blue
                                            .shade200,
                                    child: const Icon(
                                        Icons
                                            .person,
                                        color: Colors
                                            .blue),
                                  ),
                                  const SizedBox(
                                      width:
                                          12),
                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget
                                              .owner
                                              .nombreCompleto,
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize:
                                                16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Manzana: ${widget.owner.manzana} | Villa: ${widget.owner.villa}',
                                          style: TextStyle(
                                            fontSize:
                                                12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                            height: 32),
                        Text(
                          'Información del Cónyuge',
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .w600),
                        ),
                        const SizedBox(
                            height: 16),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              DropdownButtonFormField<
                                  String>(
                                value: _tipoIdentificacionController
                                    .text,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Tipo de Identificación',
                                  prefixIcon:
                                      const Icon(
                                          Icons
                                              .badge),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                items: [
                                  'Cedula',
                                  'RUC',
                                  'Pasaporte',
                                  'Otro'
                                ]
                                    .map((tipo) =>
                                        DropdownMenuItem(
                                          value:
                                              tipo,
                                          child: Text(
                                              tipo),
                                        ))
                                    .toList(),
                                onChanged:
                                    (value) {
                                  setState(
                                      () {
                                    _tipoIdentificacionController.text =
                                        value ??
                                            'Cedula';
                                  });
                                },
                                validator:
                                    (value) {
                                  if (value
                                          ?.isEmpty ??
                                      true) {
                                    return 'El tipo de identificación es requerido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: 12),
                              TextFormField(
                                controller:
                                    _identificacionController,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Identificación',
                                  prefixIcon:
                                      const Icon(
                                          Icons
                                              .card_giftcard),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                validator:
                                    (value) {
                                  if (value
                                          ?.isEmpty ??
                                      true) {
                                    return 'La identificación es requerida';
                                  }
                                  if (!FormatRules.isValidId(
                                      value!)) {
                                    return 'Cédula inválida (10 dígitos)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: 12),
                              TextFormField(
                                controller:
                                    _nombreController,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Nombres',
                                  prefixIcon:
                                      const Icon(
                                          Icons
                                              .person),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                validator:
                                    (value) {
                                  if (value
                                          ?.isEmpty ??
                                      true) {
                                    return 'Los nombres son requeridos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: 12),
                              TextFormField(
                                controller:
                                    _apellidoController,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Apellidos',
                                  prefixIcon:
                                      const Icon(
                                          Icons
                                              .person),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                validator:
                                    (value) {
                                  if (value
                                          ?.isEmpty ??
                                      true) {
                                    return 'Los apellidos son requeridos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: 12),
                              TextFormField(
                                controller:
                                    _fechaNacimientoController,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Fecha de nacimiento (YYYY-MM-DD)',
                                  prefixIcon:
                                      const Icon(
                                          Icons
                                              .calendar_today),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                readOnly:
                                    true,
                                onTap: () async {
                                  final date =
                                      await showDatePicker(
                                    context:
                                        context,
                                    initialDate: DateTime
                                            .now()
                                        .subtract(const Duration(
                                            days: 365 *
                                                18)),
                                    firstDate:
                                        DateTime(
                                            1950),
                                    lastDate:
                                        DateTime
                                            .now(),
                                  );
                                  if (date !=
                                      null) {
                                    _fechaNacimientoController.text =
                                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                                  }
                                },
                                validator:
                                    (value) {
                                  if (value
                                              ?.isEmpty ??
                                          true) {
                                    return 'La fecha de nacimiento es requerida';
                                  }
                                  final fecha =
                                      DateTime.tryParse(
                                          value!);
                                  if (fecha ==
                                      null) {
                                    return 'Formato de fecha inválido';
                                  }
                                  final hoy =
                                      DateTime
                                          .now();
                                  final edad = hoy.year -
                                      fecha.year -
                                      (hoy.month < fecha.month || (hoy.month == fecha.month && hoy.day < fecha.day)
                                          ? 1
                                          : 0);
                                  if (fecha.isAfter(
                                      hoy)) {
                                    return 'La fecha no puede ser futura';
                                  }
                                  if (edad <
                                      18) {
                                    return 'Debe ser mayor de 18 años';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: 12),
                              TextFormField(
                                controller:
                                    _nacionalidadController,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Nacionalidad',
                                  prefixIcon:
                                      const Icon(
                                          Icons
                                              .public),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(
                                  height: 12),
                              TextFormField(
                                controller:
                                    _correoController,
                                keyboardType:
                                    TextInputType
                                        .emailAddress,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Correo electrónico',
                                  prefixIcon:
                                      const Icon(
                                          Icons
                                              .email),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                validator:
                                    (value) {
                                  if (value
                                          ?.isEmpty ??
                                      true) {
                                    return 'El correo es requerido';
                                  }
                                  if (!FormatRules.isValidEmail(
                                      value!)) {
                                    return 'Formato de correo inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: 12),
                              TextFormField(
                                controller:
                                    _celularController,
                                keyboardType:
                                    TextInputType
                                        .phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                      10),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Celular *',
                                  hintText: '09XXXXXXXX',
                                  prefixIcon: const Icon(
                                      Icons.phone),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                validator:
                                    (value) {
                                  if (value
                                          ?.isEmpty ??
                                      true) {
                                    return 'El celular es requerido';
                                  }
                                  if (!FormatRules.isValidPhone(
                                      value!)) {
                                    return 'Formato inválido: 09XXXXXXXX';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: 12),
                              TextFormField(
                                controller:
                                    _direccionAlternativaController,
                                decoration:
                                    InputDecoration(
                                  hintText:
                                      'Dirección alternativa (opcional)',
                                  prefixIcon:
                                      const Icon(
                                          Icons
                                              .location_on),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(
                                  height: 12),
                              Container(
                                padding:
                                    const EdgeInsets
                                        .all(12),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .blue
                                      .shade50,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              8),
                                  border: Border
                                      .all(
                                    color: Colors
                                        .blue
                                        .shade200,
                                  ),
                                ),
                                child: Text(
                                  'Nota: La ubicación (Manzana y Villa) será heredada automáticamente del propietario.',
                                  style: TextStyle(
                                    fontSize:
                                        12,
                                    color: Colors
                                        .blue
                                        .shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () =>
                                              Navigator.of(context).pop(),
                                      child:
                                          const Text(
                                              'Cancelar'),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 12),
                                  Expanded(
                                    child:
                                        FilledButton(
                                      onPressed: isLoading
                                          ? null
                                          : _createSpouse,
                                      child: isLoading
                                          ? const SizedBox(
                                              height:
                                                  20,
                                              width:
                                                  20,
                                              child: CircularProgressIndicator(
                                                strokeWidth:
                                                    2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Guardar Cónyuge'),
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
    );
  }
}
