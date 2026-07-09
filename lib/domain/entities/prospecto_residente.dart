class ProspectoResidente {
  final int personaId;
  final String identificacion;
  final String nombres;
  final String apellidos;
  final String? correo;
  final String? celular;
  final String tipoRegistro; // "residente" o "propietario"
  final ViviendaInfo vivienda;
  final bool puedeCrearCuenta;

  ProspectoResidente({
    required this.personaId,
    required this.identificacion,
    required this.nombres,
    required this.apellidos,
    this.correo,
    this.celular,
    required this.tipoRegistro,
    required this.vivienda,
    required this.puedeCrearCuenta,
  });

  factory ProspectoResidente.fromJson(Map<String, dynamic> json) {
    return ProspectoResidente(
      personaId: json['persona_id'],
      identificacion: json['identificacion'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      celular: json['celular'],
      tipoRegistro: json['tipo_registro'],
      vivienda: ViviendaInfo.fromJson(json['vivienda']),
      puedeCrearCuenta: json['puede_crear_cuenta'] ?? true,
    );
  }
}

class ProspectoMiembro {
  final bool existe;
  final bool? personaEncontrada;
  final int? personaId;
  final String? identificacion;
  final String? nombres;
  final String? apellidos;
  final String? correo;
  final String? celular;
  final String? parentesco;
  final ViviendaInfo? vivienda;
  final bool? puedeCrearCuenta;
  final String? mensaje;
  final bool? tieneFacialEnrolado;

  ProspectoMiembro({
    required this.existe,
    this.personaEncontrada,
    this.personaId,
    this.identificacion,
    this.nombres,
    this.apellidos,
    this.correo,
    this.celular,
    this.parentesco,
    this.vivienda,
    this.puedeCrearCuenta,
    this.mensaje,
    this.tieneFacialEnrolado,
  });

  factory ProspectoMiembro.fromJson(Map<String, dynamic> json) {
    return ProspectoMiembro(
      existe: json['existe'] ?? false,
      personaEncontrada: json['persona_encontrada'],
      personaId: json['persona_id'],
      identificacion: json['identificacion'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      correo: json['correo'],
      celular: json['celular'],
      parentesco: json['parentesco'],
      vivienda: json['vivienda'] != null ? ViviendaInfo.fromJson(json['vivienda']) : null,
      puedeCrearCuenta: json['puede_crear_cuenta'],
      mensaje: json['mensaje'],
      tieneFacialEnrolado: json['tiene_facial_enrolado'] as bool?,
    );
  }
}

class ViviendaInfo {
  final int viviendaId;
  final String manzana;
  final String villa;

  ViviendaInfo({
    required this.viviendaId,
    required this.manzana,
    required this.villa,
  });

  factory ViviendaInfo.fromJson(Map<String, dynamic> json) {
    return ViviendaInfo(
      viviendaId: json['vivienda_id'],
      manzana: json['manzana'],
      villa: json['villa'],
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

class CuentaResponse {
  final int id;
  final String firebaseUid;
  final int personaId;
  final String nombres;
  final String mensaje;

  CuentaResponse({
    required this.id,
    required this.firebaseUid,
    required this.personaId,
    required this.nombres,
    required this.mensaje,
  });

  factory CuentaResponse.fromJson(Map<String, dynamic> json) {
    return CuentaResponse(
      id: json['id'],
      firebaseUid: json['firebase_uid'],
      personaId: json['persona_id'],
      nombres: json['nombres'],
      mensaje: json['mensaje'] ?? '',
    );
  }
}
