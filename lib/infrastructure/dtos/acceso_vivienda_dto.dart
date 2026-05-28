import '../../domain/entities/access_log.dart';

class AccesosViviendaDTO {
  final int viviendaId;
  final String manzana;
  final String villa;
  final int totalAccesos;
  final List<AccesoDTO> accesos;

  AccesosViviendaDTO({
    required this.viviendaId,
    required this.manzana,
    required this.villa,
    required this.totalAccesos,
    required this.accesos,
  });

  factory AccesosViviendaDTO.fromJson(Map<String, dynamic> json) {
    return AccesosViviendaDTO(
      viviendaId: json['vivienda_id'] ?? 0,
      manzana: json['manzana'] ?? '',
      villa: json['villa'] ?? '',
      totalAccesos: json['total_accesos'] ?? 0,
      accesos: (json['accesos'] as List<dynamic>?)
              ?.map((item) => AccesoDTO.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'vivienda_id': viviendaId,
        'manzana': manzana,
        'villa': villa,
        'total_accesos': totalAccesos,
        'accesos': accesos.map((a) => a.toJson()).toList(),
      };

  List<AccessLog> toEntity() =>
      accesos.map((acceso) => acceso.toEntity()).toList();
}

class AccesoDTO {
  final int accesoPk;
  final String tipo; // qr_residente, qr_visita, visita_sin_qr, manual_guardia
  final int viviendaVisitaFk;
  final String resultado; // autorizado, rechazado, codigo_expirado, cuenta_bloqueada
  final String? motivo;
  final String? placaDetectada;
  final bool biometriaOk;
  final bool placaOk;
  final int intentos;
  final String? observacion;
  final DateTime fechaCreado;
  final String? guardiaNombre;
  final String? residenteAutorizaNombre;
  final String? visitaNombres;

  AccesoDTO({
    required this.accesoPk,
    required this.tipo,
    required this.viviendaVisitaFk,
    required this.resultado,
    this.motivo,
    this.placaDetectada,
    required this.biometriaOk,
    required this.placaOk,
    required this.intentos,
    this.observacion,
    required this.fechaCreado,
    this.guardiaNombre,
    this.residenteAutorizaNombre,
    this.visitaNombres,
  });

  factory AccesoDTO.fromJson(Map<String, dynamic> json) {
    return AccesoDTO(
      accesoPk: json['acceso_pk'] ?? 0,
      tipo: json['tipo'] ?? '',
      viviendaVisitaFk: json['vivienda_visita_fk'] ?? 0,
      resultado: json['resultado'] ?? '',
      motivo: json['motivo'],
      placaDetectada: json['placa_detectada'],
      biometriaOk: json['biometria_ok'] ?? false,
      placaOk: json['placa_ok'] ?? false,
      intentos: json['intentos'] ?? 0,
      observacion: json['observacion'],
      fechaCreado: json['fecha_creado'] is String
          ? DateTime.parse(json['fecha_creado'])
          : DateTime.now(),
      guardiaNombre: json['guardia_nombre'],
      residenteAutorizaNombre: json['residente_autoriza_nombre'],
      visitaNombres: json['visita_nombres'],
    );
  }

  Map<String, dynamic> toJson() => {
        'acceso_pk': accesoPk,
        'tipo': tipo,
        'vivienda_visita_fk': viviendaVisitaFk,
        'resultado': resultado,
        'motivo': motivo,
        'placa_detectada': placaDetectada,
        'biometria_ok': biometriaOk,
        'placa_ok': placaOk,
        'intentos': intentos,
        'observacion': observacion,
        'fecha_creado': fechaCreado.toIso8601String(),
        'guardia_nombre': guardiaNombre,
        'residente_autoriza_nombre': residenteAutorizaNombre,
        'visita_nombres': visitaNombres,
      };

  AccessLog toEntity() {
    return AccessLog(
      personId: accesoPk.toString(),
      personName: visitaNombres ?? 'Desconocido',
      roleLabel: tipo,
      timestamp: fechaCreado,
      success: resultado == 'autorizado',
      reason: motivo,
      referencedBy: residenteAutorizaNombre,
    );
  }
}
