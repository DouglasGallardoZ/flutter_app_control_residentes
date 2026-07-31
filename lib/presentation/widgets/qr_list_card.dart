import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/qr_generado.dart';
import '../../application/blocs/qr_list/qr_list_bloc.dart';
import '../../application/blocs/qr_list/qr_list_event.dart';

class QrListCard extends StatelessWidget {
  final QrGenerado qr;
  final VoidCallback onVerQr;

  const QrListCard({
    super.key,
    required this.qr,
    required this.onVerQr,
  });

  String _formatearFecha(DateTime fecha) {
    final meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    final mes = meses[fecha.month - 1];
    final dia = fecha.day;
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia $mes, $hora:$minuto';
  }

  String _calcularTiempoRestante(DateTime horaFin) {
    final ahora = DateTime.now();
    if (ahora.isAfter(horaFin)) {
      return 'Expirado';
    }

    final diferencia = horaFin.difference(ahora);

    if (diferencia.inHours >= 24) {
      return '${diferencia.inDays}d ${diferencia.inHours.remainder(24)}h';
    } else if (diferencia.inHours > 0) {
      return '${diferencia.inHours}h ${diferencia.inMinutes.remainder(60)}m';
    } else if (diferencia.inMinutes > 0) {
      return '${diferencia.inMinutes}m';
    } else {
      return 'A punto de expirar';
    }
  }

  Color _statusColor(String estado) {
    switch (estado) {
      case 'vigente':
        return const Color(0xFF4CAF50);
      case 'expirado':
        return const Color(0xFFFF9800);
      case 'usado':
        return const Color(0xFF2196F3);
      case 'anulado':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
    }
  }

  void _confirmarAnular(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Anular QR'),
        content: const Text(
            '¿Estás seguro de anular este código QR? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              try {
                context.read<QrListBloc>().add(
                      AnularQr(qrId: qr.qrPk),
                    );
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text('Error al anular QR: $e'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Anular'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey.shade900 : Colors.grey.shade50;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    final ahora = DateTime.now();
    final estadoEfectivo = (qr.estado == 'vigente' && ahora.isAfter(qr.horaFin))
        ? 'expirado'
        : qr.estado;

    final statusLabel = switch (estadoEfectivo) {
      'vigente' => 'Vigente',
      'expirado' => 'Expirado',
      'usado' => 'Usado',
      'anulado' => 'Anulado',
      _ => qr.estado,
    };

    return Card(
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Tipo, Nombre y Estado
            Row(
              children: [
                // Badge de tipo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    qr.tipoIngreso == 'propio' ? 'Propio' : 'Visita',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Nombre
                Expanded(
                  child: Text(
                    qr.displayNombre,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(estadoEfectivo).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _statusColor(estadoEfectivo),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Divider
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 12),
            // Info: Inicio, Fin y Duración
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inicio',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatearFecha(qr.horaInicio),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fin',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatearFecha(qr.horaFin),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiempo restante',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _calcularTiempoRestante(qr.horaFin),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: estadoEfectivo == 'vigente' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Divider
            Divider(height: 1, color: borderColor),
            const SizedBox(height: 12),
            // Botón Ver QR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onVerQr,
                icon: const Icon(Icons.qr_code_2, size: 18),
                label: const Text('Ver QR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (estadoEfectivo == 'vigente') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmarAnular(context),
                  icon: const Icon(Icons.cancel_outlined,
                      size: 18, color: Colors.red),
                  label: const Text('Anular',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
