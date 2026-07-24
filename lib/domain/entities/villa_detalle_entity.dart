class PropietarioDetalle {
  final int personaId;
  final String nombres;
  final String apellidos;
  final String identificacion;
  final String? correo;
  final String? celular;
  final String tipo;
  final String estado;

  const PropietarioDetalle({
    required this.personaId,
    required this.nombres,
    required this.apellidos,
    required this.identificacion,
    this.correo,
    this.celular,
    required this.tipo,
    required this.estado,
  });

  factory PropietarioDetalle.fromJson(
      Map<String, dynamic> json) {
    return PropietarioDetalle(
      personaId:
          json['persona_id'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidos:
          json['apellidos'] ?? '',
      identificacion:
          json['identificacion'] ?? '',
      correo: json['correo'],
      celular: json['celular'],
      tipo: json['tipo'] ?? 'titular',
      estado:
          json['estado'] ?? 'activo',
    );
  }

  String get nombreCompleto =>
      '$nombres $apellidos';
}

class ResidenteDetalle {
  final int personaId;
  final String nombres;
  final String apellidos;
  final String identificacion;
  final String? correo;
  final String? celular;
  final String estado;

  const ResidenteDetalle({
    required this.personaId,
    required this.nombres,
    required this.apellidos,
    required this.identificacion,
    this.correo,
    this.celular,
    required this.estado,
  });

  factory ResidenteDetalle.fromJson(
      Map<String, dynamic> json) {
    return ResidenteDetalle(
      personaId:
          json['persona_id'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidos:
          json['apellidos'] ?? '',
      identificacion:
          json['identificacion'] ?? '',
      correo: json['correo'],
      celular: json['celular'],
      estado:
          json['estado'] ?? 'activo',
    );
  }

  String get nombreCompleto =>
      '$nombres $apellidos';
}

class MiembroDetalle {
  final int personaId;
  final String nombres;
  final String apellidos;
  final String identificacion;
  final String parentesco;
  final String estado;
  final int residenteId;
  final String residenteNombre;

  const MiembroDetalle({
    required this.personaId,
    required this.nombres,
    required this.apellidos,
    required this.identificacion,
    required this.parentesco,
    required this.estado,
    required this.residenteId,
    required this.residenteNombre,
  });

  factory MiembroDetalle.fromJson(
      Map<String, dynamic> json) {
    return MiembroDetalle(
      personaId:
          json['persona_id'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidos:
          json['apellidos'] ?? '',
      identificacion:
          json['identificacion'] ?? '',
      parentesco:
          json['parentesco'] ?? '',
      estado:
          json['estado'] ?? 'activo',
      residenteId:
          json['residente_id'] ?? 0,
      residenteNombre:
          json['residente_nombre'] ?? '',
    );
  }

  String get nombreCompleto =>
      '$nombres $apellidos';
}

class VillaDetalleEntity {
  final int viviendaId;
  final String manzana;
  final String villa;
  final String estado;
  final List<PropietarioDetalle>
      propietarios;
  final List<ResidenteDetalle> residentes;
  final List<MiembroDetalle> miembros;

  const VillaDetalleEntity({
    required this.viviendaId,
    required this.manzana,
    required this.villa,
    required this.estado,
    this.propietarios = const [],
    this.residentes = const [],
    this.miembros = const [],
  });

  factory VillaDetalleEntity.fromJson(
      Map<String, dynamic> json) {
    return VillaDetalleEntity(
      viviendaId:
          json['vivienda_id'] ?? 0,
      manzana:
          json['manzana'] ?? '',
      villa: json['villa'] ?? '',
      estado:
          json['estado'] ?? 'activo',
      propietarios: (json['propietarios']
                      as List<
                          dynamic>?)
              ?.map((p) =>
                  PropietarioDetalle
                      .fromJson(p
                          as Map<String,
                              dynamic>))
              .toList() ??
          [],
      residentes: (json['residentes']
                      as List<
                          dynamic>?)
              ?.map((r) =>
                  ResidenteDetalle
                      .fromJson(r
                          as Map<String,
                              dynamic>))
              .toList() ??
          [],
      miembros: (json['miembros']
                      as List<
                          dynamic>?)
              ?.map((m) =>
                  MiembroDetalle.fromJson(
                      m as Map<String,
                          dynamic>))
              .toList() ??
          [],
    );
  }
}
