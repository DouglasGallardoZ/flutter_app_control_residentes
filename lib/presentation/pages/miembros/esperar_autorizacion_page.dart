import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/blocs/autorizacion_miembro/autorizacion_miembro_bloc.dart';
import '../../../injection.dart';

class EsperarAutorizacionPage extends StatefulWidget {
  final String identificacion;
  final String nombres;
  final String apellidos;
  final String parentesco;
  final String manzana;
  final String villa;
  final String fechaNacimiento;
  final String? correo;
  final String? celular;
  final String identificacionResidente;
  final int notificacionId;

  const EsperarAutorizacionPage({
    super.key,
    required this.identificacion,
    required this.nombres,
    required this.apellidos,
    required this.parentesco,
    required this.manzana,
    required this.villa,
    required this.fechaNacimiento,
    this.correo,
    this.celular,
    required this.identificacionResidente,
    required this.notificacionId,
  });

  @override
  State<EsperarAutorizacionPage> createState() =>
      _EsperarAutorizacionPageState();
}

class _EsperarAutorizacionPageState
    extends State<EsperarAutorizacionPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<AutorizacionMiembroBloc>();
        if (widget.notificacionId > 0) {
          bloc.add(IniciarPollingConNotificacionId(
            notificacionId: widget.notificacionId,
            identificacion: widget.identificacion,
          ));
        } else {
          bloc.add(IniciarPollingConIdentificacion(
            identificacion: widget.identificacion,
          ));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
              'Autorización Pendiente'),
        ),
        body:
            BlocListener<AutorizacionMiembroBloc,
                AutorizacionMiembroState>(
          listener: (context, state) {
            if (state
                is AutorizacionAprobada) {
              Navigator.pushReplacementNamed(
                context,
                '/memberFacialEnrollment',
                arguments: {
                  'personaId':
                      state.personaId,
                  'nombres':
                      widget.nombres,
                  'apellidos':
                      widget.apellidos,
                  'type': 'member',
                },
              );
            } else if (state
                is AutorizacionRechazada) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  title: const Text(
                      'Solicitud Rechazada'),
                  content: Text(state.motivo ??
                      'El titular rechazó tu solicitud.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator
                            .pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: const Text(
                          'Volver al inicio'),
                    ),
                  ],
                ),
              );
            } else if (state is AutorizacionMiembroError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensaje
                      .replaceAll('Error al enviar solicitud: ', '')),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: BlocBuilder<
              AutorizacionMiembroBloc,
              AutorizacionMiembroState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(
                        minHeight: MediaQuery.of(
                                        context)
                                    .size
                                    .height -
                                200,
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          if (state
                              is SolicitudEnviando)
                            const CircularProgressIndicator()
                          else if (state
                              is EsperandoAutorizacion)
                            const Icon(
                                Icons
                                    .hourglass_empty,
                                size: 80,
                                color: Colors
                                    .orange)
                          else if (state
                              is AutorizacionMiembroError)
                            const Icon(
                                Icons
                                    .error_outline,
                                size: 80,
                                color:
                                    Colors.red),
                          const SizedBox(
                              height: 24),
                          Text(
                            _getMensaje(state),
                            textAlign:
                                TextAlign
                                    .center,
                            style: Theme.of(
                                    context)
                                .textTheme
                                .headlineSmall,
                          ),
                          const SizedBox(
                              height: 16),
                          Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .all(16),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    Icons
                                        .person,
                                    '${widget.nombres} ${widget.apellidos}',
                                  ),
                                  const SizedBox(
                                      height:
                                          8),
                                  _buildInfoRow(
                                    Icons
                                        .family_restroom,
                                    'Parentesco: ${widget.parentesco}',
                                  ),
                                  const SizedBox(
                                      height:
                                          8),
                                  _buildInfoRow(
                                    Icons
                                        .location_on,
                                    'Mz ${widget.manzana}, Villa ${widget.villa}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (state
                              is EsperandoAutorizacion) ...[
                            const SizedBox(
                                height: 16),
                            Text(
                              'Revisando cada 5 segundos...',
                              style: TextStyle(
                                  color: Colors
                                      .grey[500],
                                  fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getMensaje(
      AutorizacionMiembroState state) {
    if (state is SolicitudEnviando) {
      return 'Enviando solicitud...';
    }
    if (state is EsperandoAutorizacion) {
      return state.mensaje;
    }
    if (state is AutorizacionMiembroError) {
      return state.mensaje;
    }
    return 'Procesando...';
  }

  Widget _buildInfoRow(
      IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18,
            color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style:
                  const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
