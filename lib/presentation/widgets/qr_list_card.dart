import 'package:flutter/material.dart';
import '../../domain/entities/qr_generado.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey.shade900 : Colors.grey.shade50;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

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
                    color: _statusColor(qr.estado).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    qr.statusLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _statusColor(qr.estado),
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
                          color: qr.isVigente ? Colors.green : Colors.orange,
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
          ],
        ),
      ),
    );
  }
}
