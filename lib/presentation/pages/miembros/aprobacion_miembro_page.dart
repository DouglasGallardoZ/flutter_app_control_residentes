import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/blocs/aprobacion_miembro/aprobacion_miembro_bloc.dart';
import '../../../domain/entities/solicitud_miembro.dart';
import '../../../injection.dart';

class AprobacionMiembroPage extends StatelessWidget {
  const AprobacionMiembroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AprobacionMiembroBloc>(
      create: (_) => sl<AprobacionMiembroBloc>()
        ..add(CargarSolicitudesPendientes()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
              'Solicitudes de Miembros'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.of(context).pop(),
          ),
        ),
        body: BlocConsumer<AprobacionMiembroBloc,
            AprobacionMiembroState>(
          listener: (context, state) {
            if (state
                is SolicitudAprobadaExitosa) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content:
                      Text(state.mensaje),
                  backgroundColor:
                      Colors.green,
                ),
              );
            } else if (state
                is SolicitudRechazadaExitosa) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content:
                      Text(state.mensaje),
                  backgroundColor:
                      Colors.orange,
                ),
              );
            } else if (state
                is AprobacionMiembroError) {
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
            return switch (state) {
              AprobacionMiembroInicial() ||
              AprobacionMiembroCargando() =>
                const Center(
                  child:
                      CircularProgressIndicator(),
                ),
              AprobacionMiembroVacio() =>
                Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Icon(
                          Icons
                              .check_circle_outline,
                          size: 80,
                          color:
                              Colors
                                  .grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay solicitudes pendientes',
                        style: Theme.of(
                                context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color: Colors
                              .grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              SolicitudesPendientesCargadas(
                :final solicitudes
              ) =>
                RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<
                            AprobacionMiembroBloc>()
                        .add(
                            CargarSolicitudesPendientes());
                  },
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(16),
                    itemCount:
                        solicitudes.length,
                    itemBuilder:
                        (context, index) {
                      return _SolicitudCard(
                        solicitud:
                            solicitudes[index],
                        onAprobar: () {
                          _mostrarConfirmacionAprobar(
                              context,
                              solicitudes[
                                  index]);
                        },
                        onRechazar: () {
                          _mostrarDialogoRechazar(
                              context,
                              solicitudes[
                                  index]);
                        },
                      );
                    },
                  ),
                ),
              AprobacionMiembroProcesando(
                :final mensaje
              ) =>
                Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(mensaje),
                    ],
                  ),
                ),
              AprobacionMiembroError(
                :final mensaje
              ) =>
                Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red),
                      const SizedBox(height: 16),
                      Text(mensaje,
                          textAlign:
                              TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<
                                  AprobacionMiembroBloc>()
                              .add(
                                  CargarSolicitudesPendientes());
                        },
                        child: const Text(
                            'Reintentar'),
                      ),
                    ],
                  ),
                ),
              SolicitudAprobadaExitosa() ||
              SolicitudRechazadaExitosa() =>
                const Center(
                  child: Text(
                      'Actualizando...'),
                ),
            };
          },
        ),
      ),
    );
  }

  void _mostrarConfirmacionAprobar(
    BuildContext context,
    SolicitudMiembro solicitud,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            const Text('Confirmar Aprobación'),
        content: Text(
          '¿Estás seguro de aprobar a ${solicitud.nombreCompleto} '
          'como ${solicitud.parentesco} en ${solicitud.direccion}?',
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
              context
                  .read<
                      AprobacionMiembroBloc>()
                  .add(AprobarSolicitud(
                      solicitud
                          .notificacionId));
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

  void _mostrarDialogoRechazar(
    BuildContext context,
    SolicitudMiembro solicitud,
  ) {
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
            Text(
                '¿Rechazar la solicitud de ${solicitud.nombreCompleto}?'),
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
              final motivo =
                  motivoController.text
                      .trim();
              context
                  .read<
                      AprobacionMiembroBloc>()
                  .add(RechazarSolicitud(
                    solicitud
                        .notificacionId,
                    motivo: motivo.isNotEmpty
                        ? motivo
                        : null,
                  ));
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
}

class _SolicitudCard extends StatelessWidget {
  final SolicitudMiembro solicitud;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;

  const _SolicitudCard({
    required this.solicitud,
    required this.onAprobar,
    required this.onRechazar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Colors.blue.shade100,
                  child: Icon(Icons.person_add,
                      color:
                          Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        solicitud.nombreCompleto,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${solicitud.parentesco}${solicitud.parentescoOtroDesc != null ? " (${solicitud.parentescoOtroDesc})" : ""}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Colors
                                  .grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Cédula',
              value: solicitud
                  .identificacion,
            ),
            const SizedBox(height: 4),
            _InfoRow(
              icon:
                  Icons.location_on_outlined,
              label: 'Dirección',
              value: solicitud.direccion,
            ),
            if (solicitud.fechaSolicitud !=
                null) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Fecha',
                value:
                    solicitud.fechaSolicitud!,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRechazar,
                    icon: const Icon(
                        Icons.close,
                        color: Colors.red),
                    label: const Text(
                        'Rechazar',
                        style: TextStyle(
                            color:
                                Colors.red)),
                    style: OutlinedButton
                        .styleFrom(
                      side: const BorderSide(
                          color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAprobar,
                    icon: const Icon(
                        Icons.check),
                    label:
                        const Text('Aprobar'),
                    style: FilledButton
                        .styleFrom(
                      backgroundColor:
                          Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13)),
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
