class SolicitudMiembro {
  final int notificacionId;
  final String nombres;
  final String apellidos;
  final String identificacion;
  final String parentesco;
  final String? parentescoOtroDesc;
  final String manzana;
  final String villa;
  final String? fechaSolicitud;

  SolicitudMiembro({
    required this.notificacionId,
    required this.nombres,
    required this.apellidos,
    required this.identificacion,
    required this.parentesco,
    this.parentescoOtroDesc,
    required this.manzana,
    required this.villa,
    this.fechaSolicitud,
  });

  factory SolicitudMiembro.fromJson(
      Map<String, dynamic> json) {
    return SolicitudMiembro(
      notificacionId:
          json['notificacion_id'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      identificacion:
          json['identificacion'] ?? '',
      parentesco: json['parentesco'] ?? '',
      parentescoOtroDesc:
          json['parentesco_otro_desc'],
      manzana: json['manzana'] ?? '',
      villa: json['villa'] ?? '',
      fechaSolicitud:
          json['fecha_solicitud'],
    );
  }

  String get nombreCompleto =>
      '$nombres $apellidos';

  String get direccion =>
      'Mz $manzana, Villa $villa';
}
