class OwnerEntity {
  final int id;
  final String nombre;
  final String apellido;
  final String identificacion;
  final String manzana;
  final String villa;
  final String correo;
  final String celular;
  final String estado;
  final String? tipoPropietario;
  final DateTime? fechaCreacion;

  OwnerEntity({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.identificacion,
    required this.manzana,
    required this.villa,
    required this.correo,
    required this.celular,
    required this.estado,
    this.tipoPropietario,
    this.fechaCreacion,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();
  bool get isBlocked => estado != 'activo';

  OwnerEntity copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? identificacion,
    String? manzana,
    String? villa,
    String? correo,
    String? celular,
    String? estado,
    String? tipoPropietario,
    DateTime? fechaCreacion,
  }) {
    return OwnerEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      identificacion: identificacion ?? this.identificacion,
      manzana: manzana ?? this.manzana,
      villa: villa ?? this.villa,
      correo: correo ?? this.correo,
      celular: celular ?? this.celular,
      estado: estado ?? this.estado,
      tipoPropietario: tipoPropietario ?? this.tipoPropietario,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  String toString() => 'OwnerEntity(id: $id, nombre: $nombreCompleto)';
}
