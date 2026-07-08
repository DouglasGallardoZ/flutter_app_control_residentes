import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/blocs/admin/admin_notificaciones_bloc.dart';
import '../../../injection.dart';

class AdminNotificacionesPage extends StatefulWidget {
  const AdminNotificacionesPage({super.key});

  @override
  State<AdminNotificacionesPage> createState() =>
      _AdminNotificacionesPageState();
}

class _AdminNotificacionesPageState
    extends State<AdminNotificacionesPage> {
  final _tituloController = TextEditingController();
  final _mensajeController = TextEditingController();
  final _villaController = TextEditingController();
  final _busquedaController = TextEditingController();

  String _prioridad = 'normal';
  String _categoria = 'general';
  bool _enviarATodos = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
    _villaController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminNotificacionesBloc>()
        ..add(AdminDestinatariosSolicitados()),
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('Enviar Notificación'),
        ),
        body:
            BlocConsumer<AdminNotificacionesBloc,
                AdminNotificacionesState>(
          listener: _onStateChanged,
          builder: (context, state) {
            return Stepper(
              currentStep: _currentStep,
              onStepContinue: () =>
                  _onStepContinue(context, state),
              onStepCancel: _currentStep > 0
                  ? () =>
                      setState(() => _currentStep--)
                  : null,
              controlsBuilder: (context, details) =>
                  _buildControls(
                      context, state, details),
              steps: [
                Step(
                  title: const Text(
                      'Redactar mensaje'),
                  subtitle: const Text(
                      'Título, contenido y categoría'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                  content: _buildPasoMensaje(
                      context),
                ),
                Step(
                  title: const Text(
                      'Seleccionar destinatarios'),
                  subtitle: Text(
                      _getSubtitleDestinatarios(
                          state)),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                  content:
                      _buildPasoDestinatarios(
                          context, state),
                ),
                Step(
                  title: const Text(
                      'Confirmar y enviar'),
                  subtitle: const Text(
                      'Revisar antes de enviar'),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                  content:
                      _buildPasoConfirmacion(
                          context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── LISTENER ──────────────────────────────────────

  void _onStateChanged(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    if (state
        is AdminNotificacionEnviadaExito) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(state.mensaje),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _limpiarFormulario();
      setState(() => _currentStep = 0);
      context
          .read<AdminNotificacionesBloc>()
          .add(AdminDestinatariosSolicitados());
    }
    if (state is AdminNotificacionesError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(state.mensaje),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onStepContinue(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    if (_currentStep == 0) {
      if (_tituloController.text.trim().isEmpty) {
        _mostrarError('El título es requerido');
        return;
      }
      if (_mensajeController.text.trim().isEmpty) {
        _mostrarError('El mensaje es requerido');
        return;
      }
    }
    if (_currentStep == 1) {
      if (state is AdminDestinatariosCargados &&
          state.seleccionados == 0 &&
          !_enviarATodos) {
        _mostrarError(
            'Selecciona al menos un destinatario');
        return;
      }
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getSubtitleDestinatarios(
      AdminNotificacionesState state) {
    if (state is AdminDestinatariosCargados) {
      if (_enviarATodos) {
        return 'Todos los residentes';
      }
      if (state.seleccionados > 0) {
        return '${state.seleccionados} seleccionados';
      }
      return 'Ninguno seleccionado';
    }
    return 'Cargando...';
  }

  Widget _buildControls(
    BuildContext context,
    AdminNotificacionesState state,
    ControlsDetails details,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              onPressed: details.onStepCancel,
              child: const Text('Anterior'),
            ),
          const SizedBox(width: 12),
          if (_currentStep < 2)
            ElevatedButton(
              onPressed: details.onStepContinue,
              child: const Text('Siguiente'),
            ),
          if (_currentStep == 2)
            ElevatedButton.icon(
              onPressed:
                  state is AdminNotificacionEnviando
                      ? null
                      : () => _enviarNotificacion(
                          context, state),
              icon: state
                      is AdminNotificacionEnviando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(state
                      is AdminNotificacionEnviando
                  ? 'Enviando...'
                  : 'Enviar notificación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .primary,
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimary,
              ),
            ),
        ],
      ),
    );
  }

  // ─── PASO 1: REDACTAR MENSAJE ──────────────────────

  Widget _buildPasoMensaje(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _tituloController,
          decoration: const InputDecoration(
            labelText:
                'Título de la notificación',
            hintText: 'Ej: Reunión de vecinos',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _mensajeController,
          maxLines: 4,
          minLines: 3,
          decoration: const InputDecoration(
            labelText: 'Mensaje',
            hintText:
                'Escribe el contenido de la notificación...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child:
                  DropdownButtonFormField<String>(
                value: _categoria,
                decoration:
                    const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                      Icons.folder_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'general',
                    child: Text('General'),
                  ),
                  DropdownMenuItem(
                    value: 'visita',
                    child: Text('Visita'),
                  ),
                  DropdownMenuItem(
                    value: 'seguridad',
                    child: Text('Seguridad'),
                  ),
                  DropdownMenuItem(
                    value: 'pago',
                    child: Text('Pago'),
                  ),
                  DropdownMenuItem(
                    value: 'evento',
                    child: Text('Evento'),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _categoria = v!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child:
                  DropdownButtonFormField<String>(
                value: _prioridad,
                decoration:
                    const InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                      Icons.flag_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'alta',
                    child: Text('Alta'),
                  ),
                  DropdownMenuItem(
                    value: 'normal',
                    child: Text('Normal'),
                  ),
                  DropdownMenuItem(
                    value: 'baja',
                    child: Text('Baja'),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _prioridad = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildVistaPrevia(context),
      ],
    );
  }

  Widget _buildVistaPrevia(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme
          .colorScheme
          .surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smartphone,
                    size: 18,
                    color: theme.colorScheme
                        .onSurfaceVariant),
                const SizedBox(width: 8),
                Text('Vista previa',
                    style: TextStyle(
                        color: theme.colorScheme
                            .onSurfaceVariant,
                        fontWeight:
                            FontWeight.w500,
                        fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: 280,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                    color:
                        theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.05),
                    blurRadius: 4,
                    offset:
                        const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications,
                          size: 12,
                          color: theme
                              .colorScheme
                              .primary),
                      const SizedBox(width: 4),
                      Text('Guardin',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color: theme
                                  .colorScheme
                                  .primary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tituloController
                            .text.isEmpty
                        ? 'Título de la notificación'
                        : _tituloController
                            .text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color: theme.colorScheme
                          .onSurface,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _mensajeController
                            .text.isEmpty
                        ? 'Cuerpo del mensaje...'
                        : _mensajeController
                            .text,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme
                          .onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PASO 2: SELECCIONAR DESTINATARIOS ─────────────

  Widget _buildPasoDestinatarios(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _busquedaController,
          decoration: InputDecoration(
            hintText:
                'Buscar residente por nombre o identificación',
            border:
                const OutlineInputBorder(),
            prefixIcon:
                const Icon(Icons.search),
            suffixIcon: _busquedaController
                    .text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                        Icons.clear),
                    onPressed: () {
                      _busquedaController
                          .clear();
                      _aplicarFiltros(
                          context, state);
                    },
                  )
                : null,
          ),
          onSubmitted: (value) =>
              _aplicarFiltros(context, state),
        ),
        const SizedBox(height: 12),
        if (state
            is AdminDestinatariosCargados)
          _buildFiltrosUbicacion(
              context, state),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text(
              'Enviar a todos los residentes'),
          subtitle: const Text(
              'Ignora la selección manual'),
          value: _enviarATodos,
          onChanged: (v) =>
              setState(() => _enviarATodos = v),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        if (state
                is AdminDestinatariosCargados &&
            !_enviarATodos)
          Padding(
            padding:
                const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                    '${state.seleccionados} de ${state.destinatarios.length} seleccionados'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      icon: const Icon(
                          Icons.select_all,
                          size: 16),
                      label: const Text('Todos'),
                      onPressed: () => context
                          .read<
                              AdminNotificacionesBloc>()
                          .add(
                              AdminSeleccionarTodos()),
                    ),
                    TextButton.icon(
                      icon: const Icon(
                          Icons.deselect,
                          size: 16),
                      label:
                          const Text('Ninguno'),
                      onPressed: () => context
                          .read<
                              AdminNotificacionesBloc>()
                          .add(
                              AdminDeseleccionarTodos()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (state
            is AdminDestinatariosCargados)
          SizedBox(
            height: 300,
            child: Material(
              color: Colors.transparent,
              child: ListView.builder(
                itemCount: state
                    .destinatarios.length,
                itemBuilder:
                    (context, index) {
                  final d = state
                      .destinatarios[index];
                  return Card(
                    margin: const EdgeInsets
                        .only(bottom: 4),
                    elevation: 0,
                    color: d.seleccionado
                        ? Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3)
                        : null,
                    child: CheckboxListTile(
                      value:
                          d.seleccionado,
                      onChanged:
                          _enviarATodos
                              ? null
                              : (_) => context
                                  .read<
                                      AdminNotificacionesBloc>()
                                  .add(AdminDestinatarioSeleccionado(
                                      d.personaId)),
                      title: Text(
                        d.nombreCompleto,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight
                                    .w500),
                      ),
                      subtitle: Text(
                        '${d.identificacion} · ${d.direccion}',
                        style: const TextStyle(
                            fontSize: 12),
                      ),
                      secondary: CircleAvatar(
                        radius: 18,
                        backgroundColor: d.tipo ==
                                'residente'
                            ? Colors.blue
                                .withOpacity(
                                    0.1)
                            : Colors.green
                                .withOpacity(
                                    0.1),
                        child: Icon(
                          d.tipo == 'residente'
                              ? Icons.person
                              : Icons
                                  .family_restroom,
                          color: d.tipo ==
                                  'residente'
                              ? Colors.blue
                              : Colors.green,
                          size: 20,
                        ),
                      ),
                      dense: true,
                    ),
                  );
                },
              ),
            ),
          )
        else if (state
            is AdminNotificacionesCargando)
          const Center(
            child:
                CircularProgressIndicator(),
          )
        else if (state
            is AdminNotificacionesError)
          Center(
            child: Text(
                'Error: ${state.mensaje}'),
          ),
      ],
    );
  }

  Widget _buildFiltrosUbicacion(
    BuildContext context,
    AdminDestinatariosCargados state,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PopupMenuButton<String?>(
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == null) {
                _villaController.clear();
              }
              context
                  .read<
                      AdminNotificacionesBloc>()
                  .add(
                      AdminFiltroManzanaCambiado(
                          value));
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String?>(
                value: null,
                child: Text(
                    'Todas las manzanas'),
              ),
              ...state.manzanas.map((m) =>
                  PopupMenuItem<String?>(
                    value: m,
                    child:
                        Text('Manzana $m'),
                  )),
            ],
            child: Container(
              padding: const EdgeInsets
                  .symmetric(
                  horizontal: 12,
                  vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context)
                        .dividerColor),
                borderRadius:
                    BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(
                      Icons.location_on,
                      size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.manzanaSeleccionada !=
                              null
                          ? 'Manzana ${state.manzanaSeleccionada}'
                          : 'Todas las manzanas',
                      style: TextStyle(
                        fontSize: 14,
                        color: state
                                    .manzanaSeleccionada !=
                                null
                            ? null
                            : Colors.grey,
                      ),
                    ),
                  ),
                  const Icon(
                      Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: _villaController,
            decoration:
                const InputDecoration(
              hintText: 'Villa',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10),
            ),
            enabled: state
                    .manzanaSeleccionada !=
                null,
            onSubmitted: (value) {
              context
                  .read<
                      AdminNotificacionesBloc>()
                  .add(AdminFiltroVillaCambiado(
                      value.trim().isEmpty
                          ? null
                          : value.trim()));
            },
          ),
        ),
        if (state.manzanaSeleccionada !=
            null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.clear,
                size: 20),
            onPressed: () {
              _villaController.clear();
              context
                  .read<
                      AdminNotificacionesBloc>()
                  .add(
                      AdminFiltroManzanaCambiado(
                          null));
            },
          ),
        ],
      ],
    );
  }

  void _aplicarFiltros(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    final busqueda =
        _busquedaController.text.trim();
    context
        .read<AdminNotificacionesBloc>()
        .add(AdminDestinatariosSolicitados(
            busqueda: busqueda.isEmpty
                ? null
                : busqueda));
  }

  // ─── PASO 3: CONFIRMAR Y ENVIAR ─────────────────────

  Widget _buildPasoConfirmacion(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    int destinatarios = 0;
    if (state
        is AdminDestinatariosCargados) {
      destinatarios = _enviarATodos
          ? state.destinatarios.length
          : state.seleccionados;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _filaResumen(
              Icons.title,
              'Título',
              _tituloController.text,
            ),
            const Divider(height: 24),
            _filaResumen(
              Icons.folder_outlined,
              'Categoría',
              _categoria,
            ),
            const Divider(height: 24),
            _filaResumen(
              Icons.flag_outlined,
              'Prioridad',
              _prioridad,
            ),
            const Divider(height: 24),
            _filaResumen(
              Icons.people_outlined,
              'Destinatarios',
              '$destinatarios residentes',
            ),
            const SizedBox(height: 16),
            Text(
              'Mensaje:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Text(
                _mensajeController.text,
                style: const TextStyle(
                    height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaResumen(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon,
            size: 20,
            color: Theme.of(context)
                .colorScheme
                .primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // ─── ENVIAR ─────────────────────────────────────────

  void _enviarNotificacion(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    context
        .read<AdminNotificacionesBloc>()
        .add(AdminNotificacionEnviada(
          titulo:
              _tituloController.text.trim(),
          mensaje:
              _mensajeController.text.trim(),
          prioridad: _prioridad,
          categoria: _categoria,
          enviarATodos: _enviarATodos,
        ));
  }

  void _limpiarFormulario() {
    _tituloController.clear();
    _mensajeController.clear();
    _villaController.clear();
    _busquedaController.clear();
    setState(() {
      _prioridad = 'normal';
      _categoria = 'general';
      _enviarATodos = false;
      _currentStep = 0;
    });
  }
}
