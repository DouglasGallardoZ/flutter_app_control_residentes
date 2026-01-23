class ResidentDTO {
  final int personaId;
  final String identificacion;
  final String tipoIdentificacion;
  final String nombres;
  final String apellidos;
  final String fechaNacimiento;
  final String correo;
  final String celular;
  final String manzana;
  final String villa;
  final String? nacionalidad;
  final String? direccionAlternativa;
  final String? docAutorizacionPdf;
  final String estado;
  final DateTime fechaRegistro;

  ResidentDTO({
    required this.personaId,
    required this.identificacion,
    required this.tipoIdentificacion,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.correo,
    required this.celular,
    required this.manzana,
    required this.villa,
    this.nacionalidad,
    this.direccionAlternativa,
    this.docAutorizacionPdf,
    required this.estado,
    required this.fechaRegistro,
  });

  factory ResidentDTO.fromJson(Map<String, dynamic> json) {
    return ResidentDTO(
      personaId: json['persona_id'] ?? 0,
      identificacion: json['identificacion'] ?? '',
      tipoIdentificacion: json['tipo_identificacion'] ?? 'Cedula',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      fechaNacimiento: json['fecha_nacimiento'] ?? '',
      correo: json['correo'] ?? '',
      celular: json['celular'] ?? '',
      manzana: json['manzana'] ?? '',
      villa: json['villa'] ?? '',
      nacionalidad: json['nacionalidad'],
      direccionAlternativa: json['direccion_alternativa'],
      docAutorizacionPdf: json['doc_autorizacion_pdf'],
      estado: json['estado'] ?? 'activo',
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'persona_id': personaId,
      'identificacion': identificacion,
      'tipo_identificacion': tipoIdentificacion,
      'nombres': nombres,
      'apellidos': apellidos,
      'fecha_nacimiento': fechaNacimiento,
      'correo': correo,
      'celular': celular,
      'manzana': manzana,
      'villa': villa,
      'nacionalidad': nacionalidad,
      'direccion_alternativa': direccionAlternativa,
      'doc_autorizacion_pdf': docAutorizacionPdf,
      'estado': estado,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }
}

class CreateResidentRequestDTO {
  final String identificacion;
  final String tipoIdentificacion;
  final String nombres;
  final String apellidos;
  final String fechaNacimiento;
  final String correo;
  final String celular;
  final String manzana;
  final String villa;
  final String? nacionalidad;
  final String? direccionAlternativa;
  final String? docAutorizacionPdf;
  final String usuarioCreado;

  CreateResidentRequestDTO({
    required this.identificacion,
    required this.tipoIdentificacion,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.correo,
    required this.celular,
    required this.manzana,
    required this.villa,
    this.nacionalidad,
    this.direccionAlternativa,
    this.docAutorizacionPdf,
    required this.usuarioCreado,
  });

  Map<String, dynamic> toJson() {
    return {
      'identificacion': identificacion,
      'tipo_identificacion': tipoIdentificacion,
      'nombres': nombres,
      'apellidos': apellidos,
      'fecha_nacimiento': fechaNacimiento,
      'correo': correo,
      'celular': celular,
      'manzana': manzana,
      'villa': villa,
      'nacionalidad': nacionalidad,
      'direccion_alternativa': direccionAlternativa,
      'doc_autorizacion_pdf': docAutorizacionPdf,
      'usuario_creado': usuarioCreado,
    };
  }
}
