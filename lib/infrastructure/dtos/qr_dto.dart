// lib/infrastructure/dtos/qr_dto.dart

class QRResponseDTO {
  final int id;
  final String token;
  final DateTime horaInicio;
  final DateTime horaFin;
  final String estado; // vigente | expirado | utilizado
  final String tipoIngreso; // propio | visita
  final DateTime fechaCreado;
  final String? visitante; // Para QR de visita
  final String? motivo; // Para QR de visita
  final int? visitaId; // Para QR de visita

  QRResponseDTO({
    required this.id,
    required this.token,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    required this.tipoIngreso,
    required this.fechaCreado,
    this.visitante,
    this.motivo,
    this.visitaId,
  });

  factory QRResponseDTO.fromJson(Map<String, dynamic> json) {
    return QRResponseDTO(
      id: json['id'] ?? json['qr_pk'] ?? 0,
      token: json['token'] ?? '',
      horaInicio: json['hora_inicio'] is String
          ? DateTime.parse(json['hora_inicio'])
          : json['hora_inicio_vigencia'] is String
              ? DateTime.parse(json['hora_inicio_vigencia'])
              : DateTime.now(),
      horaFin: json['hora_fin'] is String
          ? DateTime.parse(json['hora_fin'])
          : json['hora_fin_vigencia'] is String
              ? DateTime.parse(json['hora_fin_vigencia'])
              : DateTime.now(),
      estado: json['estado'] ?? 'vigente',
      tipoIngreso: json['tipo_ingreso'] ?? 'propio',
      fechaCreado: json['fecha_creado'] is String
          ? DateTime.parse(json['fecha_creado'])
          : DateTime.now(),
      visitante: json['visitante'],
      motivo: json['motivo'],
      visitaId: json['visita_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'hora_inicio': horaInicio.toIso8601String(),
      'hora_fin': horaFin.toIso8601String(),
      'estado': estado,
      'tipo_ingreso': tipoIngreso,
      'fecha_creado': fechaCreado.toIso8601String(),
      if (visitante != null) 'visitante': visitante,
      if (motivo != null) 'motivo': motivo,
      if (visitaId != null) 'visita_id': visitaId,
    };
  }
}

class QRListResponseDTO {
  final List<QRResponseDTO> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;

  QRListResponseDTO({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
  });

  factory QRListResponseDTO.fromJson(Map<String, dynamic> json) {
    final qrs = (json['data'] as List?)?.map((q) => QRResponseDTO.fromJson(q)).toList() ?? [];
    return QRListResponseDTO(
      data: qrs,
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
      hasNext: json['has_next'] ?? false,
    );
  }
}
