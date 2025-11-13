class User {
  final String id;
  final String nombre;
  final String email;
  final String password;
  final String telefono;
  final String unidad;
  final String qrCode;
  final String? faceImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.telefono,
    required this.unidad,
    required this.qrCode,
    this.faceImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'password': password,
    'telefono': telefono,
    'unidad': unidad,
    'qrCode': qrCode,
    'faceImagePath': faceImagePath,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    telefono: json['telefono'] as String,
    unidad: json['unidad'] as String,
    qrCode: json['qrCode'] as String,
    faceImagePath: json['faceImagePath'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  User copyWith({
    String? id,
    String? nombre,
    String? email,
    String? password,
    String? telefono,
    String? unidad,
    String? qrCode,
    String? faceImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    email: email ?? this.email,
    password: password ?? this.password,
    telefono: telefono ?? this.telefono,
    unidad: unidad ?? this.unidad,
    qrCode: qrCode ?? this.qrCode,
    faceImagePath: faceImagePath ?? this.faceImagePath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
