import 'package:flutter/material.dart';

class QrGenerado {
  final int qrPk;
  final String token;
  final String estado; // vigente, expirado, usado, anulado
  final String tipoIngreso; // propio, visita
  final String autorizadoPorNombre; // Quien autoriza
  final String autorizadoParaNombre; // Para quien es
  final DateTime horaInicio;
  final DateTime horaFin;
  final DateTime fechaCreado;

  QrGenerado({
    required this.qrPk,
    required this.token,
    required this.estado,
    required this.tipoIngreso,
    required this.autorizadoPorNombre,
    required this.autorizadoParaNombre,
    required this.horaInicio,
    required this.horaFin,
    required this.fechaCreado,
  });

  factory QrGenerado.fromJson(Map<String, dynamic> json) {
    return QrGenerado(
      qrPk: json['qr_pk'] as int,
      token: json['token'] as String,
      estado: json['estado'] as String,
      tipoIngreso: json['tipo_ingreso'] as String,
      autorizadoPorNombre: json['autorizado_por_nombre'] as String,
      autorizadoParaNombre: json['autorizado_para'] as String,
      horaInicio: DateTime.parse(json['hora_inicio_vigencia'] as String),
      horaFin: DateTime.parse(json['hora_fin_vigencia'] as String),
      fechaCreado: DateTime.parse(json['fecha_creado'] as String),
    );
  }

  String get displayNombre => tipoIngreso == 'propio' ? autorizadoPorNombre : autorizadoParaNombre;

  bool get isVigente => estado == 'vigente';
  bool get isExpirado => estado == 'expirado';
  bool get isUsado => estado == 'usado';
  bool get isAnulado => estado == 'anulado';

  Color get statusColor {
    switch (estado) {
      case 'vigente':
        return const Color(0xFF4CAF50); // Green
      case 'expirado':
        return const Color(0xFFFF9800); // Orange
      case 'usado':
        return const Color(0xFF2196F3); // Blue
      case 'anulado':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  String get statusLabel {
    switch (estado) {
      case 'vigente':
        return 'Vigente';
      case 'expirado':
        return 'Expirado';
      case 'usado':
        return 'Usado';
      case 'anulado':
        return 'Anulado';
      default:
        return 'Desconocido';
    }
  }
}
