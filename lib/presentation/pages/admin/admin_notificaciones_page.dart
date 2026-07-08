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
  String _prioridad = 'normal';
  String _categoria = 'general';
  bool _enviarATodos = false;
  String _busqueda = '';

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
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
        body: BlocConsumer<AdminNotificacionesBloc,
            AdminNotificacionesState>(
          listener: (context, state) {
            if (state
                is AdminNotificacionEnviadaExito) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(state.mensaje),
                  backgroundColor: Colors.green,
                ),
              );
              _limpiarFormulario();
              context
                  .read<AdminNotificacionesBloc>()
                  .add(AdminDestinatariosSolicitados());
            }
            if (state
                is AdminNotificacionesError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content:
                      Text(state.mensaje),
                  backgroundColor:
                      Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder:
                  (context, constraints) {
                if (constraints.maxWidth >
                    900) {
                  return _buildDesktopLayout(
                      context, state);
                }
                return _buildMobileLayout(
                    context, state);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child:
              _buildFormulario(context, state),
        ),
        Expanded(
          flex: 2,
          child: _buildPanelDestinatarios(
              context, state),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFormulario(context, state),
          const Divider(),
          _buildPanelDestinatarios(
              context, state),
        ],
      ),
    );
  }

  Widget _buildFormulario(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    final enviando =
        state is AdminNotificacionEnviando;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text('Nueva notificación',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall),
          const SizedBox(height: 24),
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
              hintText:
                  'Ej: Reunión de vecinos',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mensajeController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Mensaje',
              border: OutlineInputBorder(),
              hintText:
                  'Escribe el mensaje de la notificación...',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(
                  value: _categoria,
                  decoration:
                      const InputDecoration(
                    labelText: 'Categoría',
                    border:
                        OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'general',
                        child:
                            Text('General')),
                    DropdownMenuItem(
                        value: 'visita',
                        child:
                            Text('Visita')),
                    DropdownMenuItem(
                        value: 'seguridad',
                        child: Text(
                            'Seguridad')),
                    DropdownMenuItem(
                        value: 'pago',
                        child: Text('Pago')),
                    DropdownMenuItem(
                        value: 'evento',
                        child:
                            Text('Evento')),
                  ],
                  onChanged: (value) =>
                      setState(() =>
                          _categoria = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(
                  value: _prioridad,
                  decoration:
                      const InputDecoration(
                    labelText: 'Prioridad',
                    border:
                        OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'alta',
                        child: Text('Alta')),
                    DropdownMenuItem(
                        value: 'normal',
                        child:
                            Text('Normal')),
                    DropdownMenuItem(
                        value: 'baja',
                        child: Text('Baja')),
                  ],
                  onChanged: (value) =>
                      setState(() =>
                          _prioridad = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
                'Enviar a todos los residentes'),
            subtitle: const Text(
                'Ignora la selección manual'),
            value: _enviarATodos,
            onChanged: (value) =>
                setState(() => _enviarATodos = value),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                              strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(enviando
                  ? 'Enviando...'
                  : 'Enviar notificación'),
              onPressed: enviando
                  ? null
                  : () => _enviar(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelDestinatarios(
    BuildContext context,
    AdminNotificacionesState state,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
              color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar residente',
                border:
                    const OutlineInputBorder(),
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                            Icons.clear),
                        onPressed: () {
                          setState(() =>
                              _busqueda = '');
                          context
                              .read<
                                  AdminNotificacionesBloc>()
                              .add(
                                  AdminDestinatariosSolicitados());
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(
                    () => _busqueda = value);
                context
                    .read<
                        AdminNotificacionesBloc>()
                    .add(AdminDestinatariosSolicitados(
                        busqueda: value));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                if (state
                    is AdminDestinatariosCargados)
                  Text(
                      '${state.seleccionados} seleccionados'),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => context
                          .read<
                              AdminNotificacionesBloc>()
                          .add(
                              AdminSeleccionarTodos()),
                      child: const Text('Todos'),
                    ),
                    TextButton(
                      onPressed: () => context
                          .read<
                              AdminNotificacionesBloc>()
                          .add(
                              AdminDeseleccionarTodos()),
                      child:
                          const Text('Ninguno'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: state
                    is AdminDestinatariosCargados
                ? ListView.builder(
                    itemCount:
                        state.destinatarios.length,
                    itemBuilder:
                        (context, index) {
                      final destinatario = state
                              .destinatarios[
                          index];
                      return CheckboxListTile(
                        value: destinatario
                            .seleccionado,
                        onChanged:
                            _enviarATodos
                                ? null
                                : (_) => context
                                    .read<
                                        AdminNotificacionesBloc>()
                                    .add(AdminDestinatarioSeleccionado(
                                        destinatario
                                            .personaId)),
                        title: Text(
                            destinatario
                                .nombreCompleto),
                        subtitle: Text(
                            '${destinatario.identificacion} ${destinatario.direccion}'),
                        secondary: CircleAvatar(
                          backgroundColor: destinatario.tipo ==
                                  'residente'
                              ? Colors.blue
                                  .withValues(alpha: 0.1)
                              : Colors.green
                                  .withValues(alpha: 0.1),
                          child: Icon(
                            destinatario.tipo ==
                                    'residente'
                                ? Icons.person
                                : Icons
                                    .family_restroom,
                            color: destinatario
                                        .tipo ==
                                    'residente'
                                ? Colors.blue
                                : Colors.green,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  )
                : state
                        is AdminNotificacionesCargando
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : const Center(
                        child: Text(
                            'Cargando destinatarios...'),
                      ),
          ),
        ],
      ),
    );
  }

  void _enviar(BuildContext context) {
    final titulo = _tituloController.text.trim();
    final mensaje =
        _mensajeController.text.trim();

    if (titulo.isEmpty || mensaje.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Título y mensaje son requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final blocBloc =
        context.read<AdminNotificacionesBloc>();
    final stateBloc = blocBloc.state;

    List<int> idsSeleccionados = [];
    if (stateBloc
        is AdminDestinatariosCargados) {
      idsSeleccionados = stateBloc.destinatarios
          .where((d) => d.seleccionado)
          .map((d) => d.personaId)
          .toList();
    }

    print('🔍 FLUTTER DEBUG:');
    print('  - enviarATodos: $_enviarATodos');
    print(
        '  - idsSeleccionados: $idsSeleccionados');
    print(
        '  - cantidad: ${idsSeleccionados.length}');

    if (!_enviarATodos &&
        idsSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              'Selecciona al menos un destinatario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    blocBloc.add(AdminNotificacionEnviada(
      titulo: titulo,
      mensaje: mensaje,
      prioridad: _prioridad,
      categoria: _categoria,
      enviarATodos: _enviarATodos,
    ));
  }

  void _limpiarFormulario() {
    _tituloController.clear();
    _mensajeController.clear();
    setState(() {
      _prioridad = 'normal';
      _categoria = 'general';
      _enviarATodos = false;
    });
  }
}
