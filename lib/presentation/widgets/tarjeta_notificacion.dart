import 'package:flutter/material.dart';
import '../../domain/entities/notificacion_item.dart';

class TarjetaNotificacion extends StatelessWidget {
  final NotificacionItem notificacion;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TarjetaNotificacion({
    super.key,
    required this.notificacion,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notificacion.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete,
            color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(
                    'Eliminar notificación'),
                content: const Text(
                    '¿Estás seguro de eliminar esta notificación?'),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(ctx, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(ctx, true),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 4),
        child: ListTile(
          leading: _buildIcono(),
          title: Text(
            notificacion.titulo,
            style: TextStyle(
              fontWeight: notificacion.leido
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(notificacion.cuerpo,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                notificacion.tiempoTranscurrido,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: _buildIndicadores(),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildIcono() {
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

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icono, color: color, size: 20),
    );
  }

  Widget _buildIndicadores() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!notificacion.leido)
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        if (notificacion.esPrioridadAlta)
          const Icon(Icons.flag,
              color: Colors.red, size: 16),
      ],
    );
  }
}
