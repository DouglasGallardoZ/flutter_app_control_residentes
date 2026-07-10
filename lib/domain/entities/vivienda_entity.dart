class ViviendaEntity {
  final int viviendaId;
  final String manzana;
  final String villa;
  final String estado;
  final int totalResidentes;
  final int totalMiembros;
  final DateTime? fechaCreado;
  final DateTime? fechaActualizado;

  const ViviendaEntity({
    required this.viviendaId,
    required this.manzana,
    required this.villa,
    required this.estado,
    required this.totalResidentes,
    required this.totalMiembros,
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
