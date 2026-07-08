import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/blocs/notificaciones/notificaciones_bloc.dart';
import '../../widgets/tarjeta_notificacion.dart';
import 'notificacion_detalle_page.dart';
import '../../../injection.dart';

class NotificacionesListaPage extends StatelessWidget {
  final String usuarioId;

  const NotificacionesListaPage({
    super.key,
    required this.usuarioId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificacionesBloc>()
        ..add(NotificacionesIniciadas(usuarioId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notificaciones'),
          actions: [
            BlocBuilder<NotificacionesBloc,
                NotificacionesState>(
              builder: (context, state) {
                if (state is NotificacionesCargadas &&
                    state.noLeidas > 0) {
                  return TextButton(
                    onPressed: () => context
                        .read<NotificacionesBloc>()
                        .add(TodasNotificacionesMarcadasLeidas()),
                    child: const Text(
                        'Leer todas'),
                  );
                }
                return const SizedBox
                    .shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<NotificacionesBloc,
            NotificacionesState>(
          listener: (context, state) {
            if (state
                is NotificacionesOperacionExitosa) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(
                      content:
                          Text(state.mensaje)));
            }
          },
          builder: (context, state) {
            if (state is NotificacionesCargando) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (state is NotificacionesVacias) {
              return Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                        Icons.notifications_off,
                        size: 80,
                        color:
                            Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes notificaciones',
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificacionesCargadas) {
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<NotificacionesBloc>()
                      .add(NotificacionesRefrescadas());
                },
                child: ListView.builder(
                  itemCount: state
                      .notificaciones.length,
                  itemBuilder:
                      (context, index) {
                    final notificacion = state
                        .notificaciones[
                        index];
                    return TarjetaNotificacion(
                      notificacion:
                          notificacion,
                      onTap: () {
                        if (!notificacion
                            .leido) {
                          context
                              .read<
                                  NotificacionesBloc>()
                              .add(NotificacionMarcadaLeida(
                                  notificacion
                                      .id));
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                NotificacionDetallePage(
                              notificacion:
                                  notificacion,
                            ),
                          ),
                        ).then((_) {
                          context
                              .read<
                                  NotificacionesBloc>()
                              .add(
                                  NotificacionesRefrescadas());
                        });
                      },
                      onDelete: () {
                        context
                            .read<
                                NotificacionesBloc>()
                            .add(NotificacionEliminada(
                                notificacion
                                    .id));
                      },
                    );
                  },
                ),
              );
            }

            if (state is NotificacionesError) {
              return Center(
                child: Text(
                    'Error: ${state.mensaje}'),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
