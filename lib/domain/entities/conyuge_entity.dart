class ConyugeEntity {
  final int id;
  final int propietarioId;
  final String nombre;
  final String apellido;
  final String identificacion;
  final String correo;
  final String celular;
  final String estado;
  final DateTime? fechaCreacion;

  ConyugeEntity({
    required this.id,
    required this.propietarioId,
    required this.nombre,
    required this.apellido,
    required this.identificacion,
    required this.correo,
    required this.celular,
    required this.estado,
    this.fechaCreacion,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();
  bool get isBlocked => estado != 'activo';

  factory ConyugeEntity.fromJson(Map<String, dynamic> json) {
    return ConyugeEntity(
      id: json['id'] ?? 0,
      propietarioId: json['propietario_id'] ?? json['propietarioId'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      identificacion: json['identificacion'] ?? '',
      correo: json['correo'] ?? json['email'] ?? '',
      celular: json['celular'] ?? json['telefono'] ?? '',
      estado: json['estado'] ?? 'activo',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propietario_id': propietarioId,
      'nombre': nombre,
      'apellido': apellido,
      'identificacion': identificacion,
      'correo': correo,
      'celular': celular,
      'estado': estado,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }

  ConyugeEntity copyWith({
    int? id,
    int? propietarioId,
    String? nombre,
    String? apellido,
    String? identificacion,
    String? correo,
    String? celular,
    String? estado,
    DateTime? fechaCreacion,
  }) {
    return ConyugeEntity(
      id: id ?? this.id,
      propietarioId: propietarioId ?? this.propietarioId,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      identificacion: identificacion ?? this.identificacion,
      correo: correo ?? this.correo,
      celular: celular ?? this.celular,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}

/// Entity extendida que incluye cónyuges
class OwnerWithSpousesEntity {
  final int id;
  final String nombre;
  final String apellido;
  final String identificacion;
  final String manzana;
  final String villa;
  final String correo;
  final String celular;
  final String estado;
  final DateTime? fechaCreacion;
  final List<ConyugeEntity> conyuges;

  OwnerWithSpousesEntity({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.identificacion,
    required this.manzana,
    required this.villa,
    required this.correo,
    required this.celular,
    required this.estado,
    this.fechaCreacion,
    this.conyuges = const [],
  });

  String get nombreCompleto => '$nombre $apellido'.trim();
  bool get isBlocked => estado != 'activo';

  factory OwnerWithSpousesEntity.fromJson(Map<String, dynamic> json) {
    return OwnerWithSpousesEntity(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      identificacion: json['identificacion'] ?? '',
      manzana: json['manzana'] ?? '',
      villa: json['villa'] ?? '',
      correo: json['correo'] ?? json['email'] ?? '',
      celular: json['celular'] ?? json['telefono'] ?? '',
      estado: json['estado'] ?? 'activo',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'])
          : null,
      conyuges: (json['conyuges'] as List<dynamic>?)
              ?.map((c) => ConyugeEntity.fromJson(c))
              .toList() ??
          [],
    );
  }
}
