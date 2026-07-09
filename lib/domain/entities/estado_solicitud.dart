enum EstadoSolicitud {
  pendiente,
  aprobado,
  rechazado,
  noEncontrado,
}

class EstadoSolicitudResponse {
  final EstadoSolicitud estado;
  final int? personaId;
  final int? miembroId;
  final String? motivo;

  EstadoSolicitudResponse({
    required this.estado,
    this.personaId,
    this.miembroId,
    this.motivo,
  });

  factory EstadoSolicitudResponse.fromJson(
      Map<String, dynamic> json) {
    EstadoSolicitud estado;
    switch (json['estado']) {
      case 'pendiente':
        estado = EstadoSolicitud.pendiente;
        break;
      case 'aprobado':
        estado = EstadoSolicitud.aprobado;
        break;
      case 'rechazado':
        estado = EstadoSolicitud.rechazado;
        break;
      default:
        estado =
            EstadoSolicitud.noEncontrado;
    }
    return EstadoSolicitudResponse(
      estado: estado,
      personaId: json['persona_id'],
      miembroId: json['miembro_id'],
      motivo: json['motivo'],
    );
  }
}
