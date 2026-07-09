import 'package:flutter/material.dart';
import '../../../domain/entities/notificacion_item.dart';
import '../../../application/blocs/aprobacion_miembro/aprobacion_miembro_bloc.dart';
import '../../../injection.dart';

class NotificacionDetallePage extends StatefulWidget {
  final NotificacionItem notificacion;

  const NotificacionDetallePage({
    super.key,
    required this.notificacion,
  });

  @override
  State<NotificacionDetallePage> createState() =>
      _NotificacionDetallePageState();
}

class _NotificacionDetallePageState
    extends State<NotificacionDetallePage> {
  bool _procesando = false;

  void _aprobarSolicitud() {
    final id = widget.notificacion.id;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            const Text('Confirmar Aprobación'),
        content: Text(
            '¿Estás seguro de aprobar esta solicitud de miembro?'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(
                  () => _procesando = true);
              final bloc = sl<
                  AprobacionMiembroBloc>();
              bloc.add(
                  AprobarSolicitud(id));
              bloc.stream
                  .firstWhere((s) =>
                      s is SolicitudAprobadaExitosa ||
                      s is AprobacionMiembroError)
                  .then((s) {
                if (mounted) {
                  if (s
                      is SolicitudAprobadaExitosa) {
                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                            s.mensaje),
                        backgroundColor:
                            Colors.green,
                      ),
                    );
                    Navigator.of(
                            context)
                        .pop();
                  } else {
                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      SnackBar(
                        content: Text((s
                                as AprobacionMiembroError)
                            .mensaje),
                        backgroundColor:
                            Colors.red,
                      ),
                    );
                    setState(() =>
                        _procesando =
                            false);
                  }
                }
              });
            },
            style: FilledButton.styleFrom(
                backgroundColor:
                    Colors.green),
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );
  }

  void _rechazarSolicitud() {
    final id = widget.notificacion.id;
    final motivoController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            const Text('Rechazar Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
                '¿Confirma el rechazo de esta solicitud?'),
            const SizedBox(height: 12),
            TextField(
              controller: motivoController,
              decoration:
                  const InputDecoration(
                labelText: 'Motivo (opcional)',
                border:
                    OutlineInputBorder(),
                hintText:
                    'Ej: No es familiar directo',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(
                  () => _procesando = true);
              final motivo =
                  motivoController.text
                      .trim();
              final bloc = sl<
                  AprobacionMiembroBloc>();
              bloc.add(RechazarSolicitud(
                id,
                motivo: motivo.isNotEmpty
                    ? motivo
                    : null,
              ));
              bloc.stream
                  .firstWhere((s) =>
                      s is SolicitudRechazadaExitosa ||
                      s is AprobacionMiembroError)
                  .then((s) {
                if (mounted) {
                  if (s
                      is SolicitudRechazadaExitosa) {
                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                            s.mensaje),
                        backgroundColor:
                            Colors.orange,
                      ),
                    );
                    Navigator.of(
                            context)
                        .pop();
                  } else {
                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      SnackBar(
                        content: Text((s
                                as AprobacionMiembroError)
                            .mensaje),
                        backgroundColor:
                            Colors.red,
                      ),
                    );
                    setState(() =>
                        _procesando =
                            false);
                  }
                }
              });
            },
            style: FilledButton.styleFrom(
                backgroundColor:
                    Colors.red),
            child:
                const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Detalle de Notificación'),
        actions: [
          if (widget.notificacion.rutaAccion !=
              null)
            TextButton.icon(
              icon: const Icon(
                  Icons.open_in_new),
              label: const Text('Ver más'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  widget
                      .notificacion.rutaAccion!,
                  arguments: widget
                      .notificacion.datosAccion,
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: _buildIconoCategoria(),
            ),
            const SizedBox(height: 16),
            if (widget.notificacion.esPrioridadAlta)
              Center(
                child: Container(
                  padding: const EdgeInsets
                      .symmetric(
                      horizontal: 12,
                      vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red
                        .withValues(
                            alpha: 0.1),
                    borderRadius:
                        BorderRadius
                            .circular(12),
                  ),
                  child: const Text(
                    'Prioridad Alta',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight:
                            FontWeight
                                .bold),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              widget.notificacion.titulo,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                      fontWeight:
                          FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14,
                    color:
                        Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  widget.notificacion
                      .tiempoTranscurrido,
                  style: TextStyle(
                      color:
                          Colors.grey[600],
                      fontSize: 13),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets
                      .symmetric(
                      horizontal: 8,
                      vertical: 2),
                  decoration: BoxDecoration(
                    color: _colorCategoria()
                        .withValues(
                            alpha: 0.1),
                    borderRadius:
                        BorderRadius
                            .circular(8),
                  ),
                  child: Text(
                    widget
                        .notificacion.categoria,
                    style: TextStyle(
                        color:
                            _colorCategoria(),
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              widget.notificacion.cuerpo,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(height: 1.6),
            ),
            if (widget.notificacion.tipo ==
                'solicitud_miembro') ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: _procesando
                          ? null
                          : _rechazarSolicitud,
                      icon: const Icon(
                          Icons.close,
                          color: Colors.red),
                      label: const Text(
                          'Rechazar'),
                      style: OutlinedButton
                          .styleFrom(
                        side: const BorderSide(
                            color:
                                Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child:
                        FilledButton.icon(
                      onPressed: _procesando
                          ? null
                          : _aprobarSolicitud,
                      icon: const Icon(
                          Icons.check),
                      label: const Text(
                          'Aprobar'),
                      style: FilledButton
                          .styleFrom(
                        backgroundColor:
                            Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 30),
            if (widget.notificacion.rutaAccion !=
                null)
              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton.icon(
                  icon: const Icon(
                      Icons.arrow_forward),
                  label: const Text(
                      'Ir a la acción relacionada'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      widget
                          .notificacion
                          .rutaAccion!,
                      arguments: widget
                          .notificacion
                          .datosAccion,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconoCategoria() {
    IconData icono;
    Color color;

    switch (widget.notificacion.categoria) {
      case 'seguridad':
        icono = Icons.shield;
        color = Colors.red;
        break;
      case 'visita':
        icono = Icons.people;
        color = Colors.blue;
        break;
      case 'pago':
        icono = Icons.payment;
        color = Colors.green;
        break;
      case 'evento':
        icono = Icons.event;
        color = Colors.purple;
        break;
      default:
        icono = Icons.notifications;
        color = Colors.orange;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icono,
          color: color, size: 40),
    );
  }

  Color _colorCategoria() {
    switch (widget.notificacion.categoria) {
      case 'seguridad':
        return Colors.red;
      case 'visita':
        return Colors.blue;
      case 'pago':
        return Colors.green;
      case 'evento':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }
}
