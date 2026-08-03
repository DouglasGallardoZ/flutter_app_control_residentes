import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/blocs/admin/admin_notificaciones_bloc.dart';
import '../../widgets/admin_scaffold.dart';

class AdminNotificacionesPage
    extends StatefulWidget {
  final int personaId;
  final String identificacion;

  const AdminNotificacionesPage({
    super.key,
    required this.personaId,
    required this.identificacion,
  });

  @override
  State<AdminNotificacionesPage>
  createState() =>
      _AdminNotificacionesPageState();
}

class _AdminNotificacionesPageState
    extends State<AdminNotificacionesPage> {
  int _currentStep = 0;
  final _tituloCtrl =
      TextEditingController();
  final _mensajeCtrl =
      TextEditingController();
  String _prioridad = 'normal';
  String _categoria = 'general';
  String? _manzanaFiltro;
  String? _villaFiltro;
  bool _enviarATodos = false;
  String _tipoDestinatario = 'todos';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<AdminNotificacionesBloc>()
          .add(AdminDestinatariosSolicitados());
    });
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _mensajeCtrl.dispose();
    super.dispose();
  }

  void _enviar() {
    context
        .read<AdminNotificacionesBloc>()
        .add(AdminNotificacionEnviada(
      titulo:
          _tituloCtrl.text.trim(),
      mensaje:
          _mensajeCtrl.text.trim(),
      prioridad: _prioridad,
      categoria: _categoria,
      enviarATodos: _enviarATodos,
    ));
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _tituloCtrl.clear();
      _mensajeCtrl.clear();
      _prioridad = 'normal';
      _categoria = 'general';
      _manzanaFiltro = null;
      _villaFiltro = null;
      _enviarATodos = false;
      _tipoDestinatario = 'todos';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Enviar Notificación',
      routeName:
          '/adminNotificaciones',
      showBackButton: true,
      onBackPressed: () =>
          Navigator.of(context)
              .pushReplacementNamed(
        '/adminDashboard',
        arguments: {
          'personaId':
              widget.personaId,
          'identificacion':
              widget.identificacion,
        },
      ),
      onTabSelected: (i) {
        if (i == 3) return;
        WidgetsBinding.instance
            .addPostFrameCallback((_) {
          final routes = [
            '/adminDashboard',
            // TODO: Restaurar cuando se implemente el módulo de historial
            // '/adminAccessHistory',
            '/adminUsers',
            '/adminProfile',
            null,
            '/adminViviendas',
          ];
          if (routes[i] != null) {
            Navigator.of(context)
                .pushReplacementNamed(
              routes[i]!,
              arguments: {
                'personaId':
                    widget.personaId,
                'identificacion':
                    widget.identificacion,
              },
            );
          }
        });
      },
      body: BlocConsumer<
          AdminNotificacionesBloc,
          AdminNotificacionesState>(
        listener: (context,
            state) {
          if (state
              is AdminNotificacionEnviadaExito) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(
              SnackBar(
                content: Text(
                    '${state.mensaje} (${state.enviados} destinatarios)'),
                backgroundColor:
                    Colors.green,
              ),
            );
            _resetForm();
          } else if (state
              is AdminNotificacionesError) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(
              SnackBar(
                content: Text(
                    state.mensaje),
                backgroundColor:
                    Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final theme = Theme.of(context);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Row(
                  children: [
                    _pasoIndicador(1, 'Mensaje', _currentStep >= 0, _currentStep > 0),
                    Expanded(child: Divider(color: _currentStep > 0 ? const Color(0xFF04345C) : Colors.grey.shade300, thickness: 2)),
                    _pasoIndicador(2, 'Destinatarios', _currentStep >= 1, _currentStep > 1),
                    Expanded(child: Divider(color: _currentStep > 1 ? const Color(0xFF04345C) : Colors.grey.shade300, thickness: 2)),
                    _pasoIndicador(3, 'Confirmar', _currentStep >= 2, _currentStep > 2),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text('Redacta el mensaje', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('La notificación se enviará a los destinatarios seleccionados', style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _tituloCtrl,
                            decoration: InputDecoration(
                              labelText: 'Título',
                              hintText: 'Ej: Mantenimiento programado',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _mensajeCtrl,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: 'Mensaje',
                              hintText: 'Escribe el contenido de la notificación...',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Flexible(
                                child: DropdownButtonFormField<String>(
                                  value: _prioridad,
                                  decoration: InputDecoration(
                                    labelText: 'Prioridad',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'baja', child: Text('Baja')),
                                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                                    DropdownMenuItem(value: 'alta', child: Text('Alta')),
                                  ],
                                  onChanged: (v) => setState(() => _prioridad = v ?? 'normal'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: DropdownButtonFormField<String>(
                                  value: _categoria,
                                  decoration: InputDecoration(
                                    labelText: 'Categoría',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'general', child: Text('General')),
                                    DropdownMenuItem(value: 'visita', child: Text('Visita')),
                                    DropdownMenuItem(value: 'seguridad', child: Text('Seguridad')),
                                    DropdownMenuItem(value: 'evento', child: Text('Evento')),
                                  ],
                                  onChanged: (v) => setState(() => _categoria = v ?? 'general'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: state is AdminDestinatariosCargados
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selecciona los destinatarios', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('${state.seleccionados} de ${state.destinatarios.length} seleccionados',
                                    style: TextStyle(color: Colors.grey.shade600)),
                                const SizedBox(height: 12),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _FilterChip(
                                        label: 'Todos',
                                        selected: _tipoDestinatario == 'todos',
                                        onTap: () => setState(() => _tipoDestinatario = 'todos'),
                                      ),
                                      const SizedBox(width: 8),
                                      _FilterChip(
                                        label: 'Residentes',
                                        selected: _tipoDestinatario == 'residente',
                                        onTap: () => setState(() => _tipoDestinatario = 'residente'),
                                      ),
                                      const SizedBox(width: 8),
                                      _FilterChip(
                                        label: 'Propietarios',
                                        selected: _tipoDestinatario == 'propietario',
                                        onTap: () => setState(() => _tipoDestinatario = 'propietario'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SwitchListTile(
                                  value: _enviarATodos,
                                  onChanged: (v) {
                                    setState(() => _enviarATodos = v);
                                    if (v) {
                                      context.read<AdminNotificacionesBloc>().add(AdminSeleccionarTodos());
                                    } else {
                                      context.read<AdminNotificacionesBloc>().add(AdminDeseleccionarTodos());
                                    }
                                  },
                                  title: const Text('Enviar a todos'),
                                  activeColor: const Color(0xFF04345C),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                if (!_enviarATodos) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: DropdownButtonFormField<String>(
                                          value: _manzanaFiltro,
                                          decoration: InputDecoration(
                                            labelText: 'Manzana',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                          items: [
                                            const DropdownMenuItem<String>(
                                                value: '',
                                                child: Text('Todas las manzanas',
                                                    style: TextStyle(color: Colors.grey))),
                                            ...state.manzanas
                                                .map((m) => DropdownMenuItem(value: m, child: Text(m))),
                                          ],
                                          onChanged: (v) {
                                            final valor = (v != null && v.isNotEmpty) ? v : null;
                                            setState(() => _manzanaFiltro = valor);
                                            context.read<AdminNotificacionesBloc>().add(
                                                  AdminFiltroManzanaCambiado(valor ?? ''),
                                                );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: DropdownButtonFormField<String>(
                                          value: _villaFiltro,
                                          decoration: InputDecoration(
                                            labelText: 'Villa',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                          items: [
                                            const DropdownMenuItem<String>(
                                                value: '',
                                                child: Text('Todas las villas',
                                                    style: TextStyle(color: Colors.grey))),
                                            ...state.destinatarios
                                                .where((d) => _manzanaFiltro == null ||
                                                    _manzanaFiltro!.isEmpty ||
                                                    d.manzana == _manzanaFiltro)
                                                .map((d) => d.villa)
                                                .where((v) => v != null)
                                                .toSet()
                                                .map((v) => DropdownMenuItem(value: v, child: Text(v!))),
                                          ],
                                          onChanged: (v) {
                                            final valor = (v != null && v.isNotEmpty) ? v : null;
                                            setState(() => _villaFiltro = valor);
                                            context.read<AdminNotificacionesBloc>().add(
                                                  AdminFiltroVillaCambiado(valor ?? ''),
                                                );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => context.read<AdminNotificacionesBloc>().add(AdminSeleccionarTodos()),
                                        icon: const Icon(Icons.select_all, size: 18),
                                        label: const Text('Todos'),
                                      ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () => context.read<AdminNotificacionesBloc>().add(AdminDeseleccionarTodos()),
                                        icon: const Icon(Icons.deselect, size: 18),
                                        label: const Text('Ninguno'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...state.destinatarios
                                      .where((d) => _tipoDestinatario == 'todos' || d.tipo == _tipoDestinatario)
                                      .map((d) => CheckboxListTile(
                                        value: d.seleccionado,
                                        onChanged: (_) {
                                          context.read<AdminNotificacionesBloc>().add(
                                                AdminDestinatarioSeleccionado(d.personaId),
                                              );
                                        },
                                        title: Text(d.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        subtitle: Text(
                                          '${d.tipo == 'residente' ? 'Residente' : d.tipo == 'propietario' ? 'Propietario' : 'Miembro'}'
                                          '${d.manzana != null ? ' · Mz ${d.manzana}' : ''}'
                                          '${d.villa != null ? ', V ${d.villa}' : ''}',
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                        dense: true,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                      )),
                                ],
                              ],
                            )
                          : state is AdminNotificacionesError
                              ? Center(
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                                    const SizedBox(height: 16),
                                    Text(state.mensaje, textAlign: TextAlign.center),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          context.read<AdminNotificacionesBloc>().add(AdminDestinatariosSolicitados()),
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Reintentar'),
                                    ),
                                  ]),
                                )
                              : const Center(child: CircularProgressIndicator()),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Confirma el envío', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Revisa los datos antes de enviar', style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(height: 24),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _resumenRow(Icons.title, 'Título', _tituloCtrl.text),
                                  const Divider(),
                                  _resumenRow(Icons.message, 'Mensaje', _mensajeCtrl.text, multiline: true),
                                  const Divider(),
                                  _resumenRow(Icons.flag, 'Prioridad', _prioridad),
                                  const SizedBox(height: 8),
                                  _resumenRow(Icons.category, 'Categoría', _categoria),
                                  const Divider(),
                                  _resumenRow(Icons.people, 'Destinatarios',
                                      _enviarATodos ? 'Todos los residentes' : 'Seleccionados manualmente'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: state is AdminNotificacionEnviando ? null : _enviar,
                              icon: state is AdminNotificacionEnviando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.send),
                              label: Text(state is AdminNotificacionEnviando ? 'Enviando...' : 'Enviar notificación'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_currentStep == 1)
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _currentStep--),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Atrás'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                      if (_currentStep == 1) const SizedBox(width: 12),
                      if (_currentStep < 2)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              if (_currentStep == 0) {
                                if (_tituloCtrl.text.trim().isEmpty || _mensajeCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Completa el título y mensaje')),
                                  );
                                  return;
                                }
                                context.read<AdminNotificacionesBloc>().add(AdminDestinatariosSolicitados());
                              }

                              if (_currentStep == 1) {
                                final blState = context.read<AdminNotificacionesBloc>().state;
                                if (blState is AdminDestinatariosCargados) {
                                  if (!_enviarATodos && blState.seleccionados == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Selecciona al menos un destinatario')),
                                    );
                                    return;
                                  }
                                }
                              }

                              setState(() => _currentStep++);
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(_currentStep == 1 ? 'Revisar y confirmar' : 'Siguiente'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF04345C),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                          ),
                        ),
                      if (_currentStep == 2)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _currentStep--),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Corregir'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _pasoIndicador(int numero, String label, bool activo, bool completado) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completado
                ? const Color(0xFF04345C)
                : activo
                    ? const Color(0xFF04345C).withOpacity(0.15)
                    : Colors.grey.shade200,
            border: Border.all(
              color: activo || completado ? const Color(0xFF04345C) : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: completado
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$numero',
                    style: TextStyle(
                      color: activo ? const Color(0xFF04345C) : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            color: activo || completado ? const Color(0xFF04345C) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _resumenRow(
    IconData icon,
    String label,
    String value, {
    bool multiline = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
              vertical: 4),
      child: Row(
        crossAxisAlignment:
            multiline
                ? CrossAxisAlignment
                    .start
                : CrossAxisAlignment
                    .center,
        children: [
          Icon(icon,
              size: 18,
              color: Colors
                  .grey
                  .shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
                color: Colors
                    .grey
                    .shade600,
                fontWeight:
                    FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight:
                      FontWeight
                          .w500),
              maxLines:
                  multiline ? 3 : 1,
              overflow: TextOverflow
                  .ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF04345C),
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}
