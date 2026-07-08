class NotificacionItem {
  final int id;
  final String titulo;
  final String cuerpo;
  final String tipo;
  final String prioridad;
  final String categoria;
  final bool leido;
  final DateTime? fechaCreacion;
  final String? rutaAccion;
  final Map<String, dynamic>? datosAccion;

  const NotificacionItem({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.tipo,
    required this.prioridad,
    required this.categoria,
    required this.leido,
    this.fechaCreacion,
    this.rutaAccion,
    this.datosAccion,
  });

  factory NotificacionItem.fromJson(Map<String, dynamic> json) {
    return NotificacionItem(
      id: json['notificacion_id'] is int
          ? json['notificacion_id']
          : int.tryParse(
                  json['notificacion_id']?.toString() ?? '') ??
              0,
      titulo: json['titulo'] as String? ?? '',
      cuerpo: json['cuerpo'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      prioridad: json['prioridad'] as String? ?? 'normal',
      categoria: json['categoria'] as String? ?? 'general',
      leido: json['leido'] as bool? ?? false,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(
              json['fecha_creacion'].toString())
          : null,
      rutaAccion: json['ruta_accion'] as String?,
      datosAccion:
          json['datos_accion'] as Map<String, dynamic>?,
    );
  }

  bool get esPrioridadAlta => prioridad == 'alta';

  bool get esPrioridadNormal => prioridad == 'normal';

  bool get esPrioridadBaja => prioridad == 'baja';

  String get tiempoTranscurrido {
    if (fechaCreacion == null) return '';
    final diferencia =
        DateTime.now().difference(fechaCreacion!);
    if (diferencia.inMinutes < 1) return 'Ahora';
    if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes}m';
    }
    if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours}h';
    }
    if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays}d';
    }
    return '${fechaCreacion!.day}/'
        '${fechaCreacion!.month}/'
        '${fechaCreacion!.year}';
  }
}
