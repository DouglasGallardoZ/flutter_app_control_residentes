import '../../domain/entities/owner_entity.dart';

class OwnerDTO {
  final int propietarioId;
  final String nombres;
  final String apellidos;
  final String identificacion;
  final String manzana;
  final String villa;
  final String correo;
  final String celular;
  final String estado;
  final DateTime? fechaCreacion;

  OwnerDTO({
    required this.propietarioId,
    required this.nombres,
    required this.apellidos,
    required this.identificacion,
    required this.manzana,
    required this.villa,
    required this.correo,
    required this.celular,
    required this.estado,
    this.fechaCreacion,
  });

  /// Crear desde JSON de la API
  factory OwnerDTO.fromJson(Map<String, dynamic> json) {
    return OwnerDTO(
      propietarioId: json['propietario_id'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      identificacion: json['identificacion'] ?? '',
      manzana: json['manzana'] ?? '',
      villa: json['villa'] ?? '',
      correo: json['correo'] ?? '',
      celular: json['celular'] ?? '',
      estado: json['estado'] ?? 'activo',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'])
          : null,
    );
  }

  /// Convertir a JSON para enviar a la API
  Map<String, dynamic> toJson() => {
        'propietario_id': propietarioId,
        'nombres': nombres,
        'apellidos': apellidos,
        'identificacion': identificacion,
        'manzana': manzana,
        'villa': villa,
        'correo': correo,
        'celular': celular,
        'estado': estado,
        'fecha_creacion': fechaCreacion?.toIso8601String(),
      };

  /// Convertir DTO a Entity
  OwnerEntity toEntity() => OwnerEntity(
        id: propietarioId,
        nombre: nombres,
        apellido: apellidos,
        identificacion: identificacion,
        manzana: manzana,
        villa: villa,
        correo: correo,
        celular: celular,
        estado: estado,
        fechaCreacion: fechaCreacion,
      );

  @override
  String toString() => 'OwnerDTO(id: $propietarioId, nombre: $nombres $apellidos)';
}
