// lib/infrastructure/dtos/perfil_usuario_dto.dart

class PerfilUsuarioDTO {
  final int? personaId;
  final String? identificacion;
  final String nombres;
  final String apellidos;
  final String? correo;
  final String? celular;
  final String estado;
  final String rol;
  final ViviendaDTO? vivienda;
  final String? parentesco;
  final DateTime fechaCreado;

  PerfilUsuarioDTO({
    this.personaId,
    this.identificacion,
    required this.nombres,
    required this.apellidos,
    this.correo,
    this.celular,
    required this.estado,
    required this.rol,
    this.vivienda,
    this.parentesco,
    required this.fechaCreado,
  });

  factory PerfilUsuarioDTO.fromJson(Map<String, dynamic> json) {
    return PerfilUsuarioDTO(
      personaId: json['persona_id'] != null ? int.tryParse(json['persona_id'].toString()) : null,
      identificacion: json['identificacion'],
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'],
      celular: json['celular'],
      estado: json['estado'] ?? 'activo',
      rol: json['rol'] ?? 'residente',
      vivienda: json['vivienda'] != null ? ViviendaDTO.fromJson(json['vivienda']) : null,
      parentesco: json['parentesco'],
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
      'estado': estado,
      'rol': rol,
      'vivienda': vivienda?.toJson(),
      'parentesco': parentesco,
      'fecha_creado': fechaCreado.toIso8601String(),
    };
  }
}

class ViviendaDTO {
  final int? viviendaId;
  final String manzana;
  final String villa;

  ViviendaDTO({
    this.viviendaId,
    required this.manzana,
    required this.villa,
  });

  factory ViviendaDTO.fromJson(Map<String, dynamic> json) {
    return ViviendaDTO(
      viviendaId: json['vivienda_id'] != null ? int.tryParse(json['vivienda_id'].toString()) : null,
      manzana: json['manzana'] ?? '',
      villa: json['villa'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vivienda_id': viviendaId,
      'manzana': manzana,
      'villa': villa,
    };
  }
}
