class PropietarioEnVivienda {
  final int personaId;
  final String nombres;
  final String apellidos;
  final String identificacion;
  final String? correo;
  final String? celular;
  final String tipo;
  final String estado;

  const PropietarioEnVivienda({
    required this.personaId,
    required this.nombres,
    required this.apellidos,
    required this.identificacion,
    this.correo,
    this.celular,
    required this.tipo,
    required this.estado,
  });

  factory PropietarioEnVivienda.fromJson(
      Map<String, dynamic> json) {
    return PropietarioEnVivienda(
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

class ViviendaEntity {
  final int viviendaId;
  final String manzana;
  final String villa;
  final String estado;
  final int totalResidentes;
  final int totalMiembros;
  final List<PropietarioEnVivienda>
      propietarios;
  final DateTime? fechaCreado;
  final DateTime? fechaActualizado;

  const ViviendaEntity({
    required this.viviendaId,
    required this.manzana,
    required this.villa,
    required this.estado,
    required this.totalResidentes,
    required this.totalMiembros,
    this.propietarios = const [],
    this.fechaCreado,
    this.fechaActualizado,
  });

  bool get isActivo => estado == 'activo';

  factory ViviendaEntity.fromJson(
      Map<String, dynamic> json) {
    return ViviendaEntity(
      viviendaId:
          json['vivienda_id'] as int,
      manzana:
          json['manzana'] as String? ?? '',
      villa:
          json['villa'] as String? ?? '',
      estado: json['estado']
              as String? ??
          'activo',
      totalResidentes:
          json['total_residentes']
                  as int? ??
              0,
      totalMiembros:
          json['total_miembros']
                  as int? ??
              0,
      propietarios: (json['propietarios']
                      as List<dynamic>?)
              ?.map((p) =>
                  PropietarioEnVivienda
                      .fromJson(p
                          as Map<String,
                              dynamic>))
              .toList() ??
          [],
      fechaCreado:
          json['fecha_creado'] != null
              ? DateTime.tryParse(json[
                      'fecha_creado']
                  .toString())
              : null,
      fechaActualizado: json[
                  'fecha_actualizado'] !=
              null
          ? DateTime.tryParse(json[
                  'fecha_actualizado']
              .toString())
          : null,
    );
  }
}
