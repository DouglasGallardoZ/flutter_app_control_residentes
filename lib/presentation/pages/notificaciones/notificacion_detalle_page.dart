import 'package:flutter/material.dart';
import '../../../domain/entities/notificacion_item.dart';

class NotificacionDetallePage extends StatelessWidget {
  final NotificacionItem notificacion;

  const NotificacionDetallePage({
    super.key,
    required this.notificacion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Notificación'),
        actions: [
          if (notificacion.rutaAccion != null)
            TextButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ver más'),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  notificacion.rutaAccion!,
                  arguments:
                      notificacion.datosAccion,
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
            if (notificacion.esPrioridadAlta)
              Center(
                child: Container(
                  padding: const EdgeInsets
                      .symmetric(
                      horizontal: 12,
                      vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Prioridad Alta',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight:
                            FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              notificacion.titulo,
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
                    color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  notificacion.tiempoTranscurrido,
                  style: TextStyle(
                      color: Colors.grey[600],
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
                        .withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Text(
                    notificacion.categoria,
                    style: TextStyle(
                        color: _colorCategoria(),
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              notificacion.cuerpo,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 30),
            if (notificacion.rutaAccion != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(
                      Icons.arrow_forward),
                  label: const Text(
                      'Ir a la acción relacionada'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      notificacion.rutaAccion!,
                      arguments: notificacion
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

    switch (notificacion.categoria) {
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
      child: Icon(icono, color: color, size: 40),
    );
  }

  Color _colorCategoria() {
    switch (notificacion.categoria) {
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
