// lib/infrastructure/dtos/miembro_familia_dto.dart
import '../../domain/entities/account.dart';

class MiembroFamiliaDTO {
  final int personaId;
  final String identificacion;
  final String nombres;
  final String apellidos;
  final String? correo;
  final String? celular;
  final String parentesco;
  final String estado;
  final DateTime fechaCreado;

  MiembroFamiliaDTO({
    required this.personaId,
    required this.identificacion,
    required this.nombres,
    required this.apellidos,
    this.correo,
    this.celular,
    required this.parentesco,
    required this.estado,
    required this.fechaCreado,
  });

  factory MiembroFamiliaDTO.fromJson(Map<String, dynamic> json) {
    return MiembroFamiliaDTO(
      personaId: json['persona_id'] ?? 0,
      identificacion: json['identificacion'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'],
      celular: json['celular'],
      parentesco: json['parentesco'] ?? '',
      estado: json['estado'] ?? 'activo',
      fechaCreado: json['fecha_creado'] is String
          ? DateTime.parse(json['fecha_creado'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'persona_id': personaId,
      'identificacion': identificacion,
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'celular': celular,
      'parentesco': parentesco,
      'estado': estado,
      'fecha_creado': fechaCreado.toIso8601String(),
    };
  }

  String get nombreCompleto => '$nombres $apellidos';

  Account toEntity({
    required String firebaseUid,
    required Vivienda vivienda,
  }) {
    return Account(
      firebaseUid: firebaseUid,
      personaId: personaId,
      identificacion: identificacion,
      nombres: nombres,
      apellidos: apellidos,
      rol: 'miembro_familia',
      estado: estado,
      correo: correo,
      celular: celular,
      vivienda: vivienda,
      parentesco: parentesco,
      fechaCreado: fechaCreado,
    );
  }
}
