// lib/domain/entities/account.dart
class Account {
  final String firebaseUid; // UUID de Firebase Auth
  final int personaId; // ID de persona en BD
  final String identificacion; // Cédula/Pasaporte
  final String nombres;
  final String apellidos;
  final String rol; // residente | miembro_familia
  final String estado; // activo | inactivo
  final String? correo;
  final String? celular;
  final Vivienda vivienda; // Información de vivienda
  final String? parentesco; // Para miembros de familia (padre, madre, hijo, etc.)
  final DateTime fechaCreado;

  Account({
    required this.firebaseUid,
    required this.personaId,
    required this.identificacion,
    required this.nombres,
    required this.apellidos,
    required this.rol,
    required this.estado,
    required this.vivienda,
    required this.fechaCreado,
    this.correo,
    this.celular,
    this.parentesco,
  });

  factory Account.fromMap(Map<String, dynamic> map) => Account(
        firebaseUid: map['firebaseUid'] ?? '',
        personaId: map['personaId'] ?? 0,
        identificacion: map['identificacion'] ?? '',
        nombres: map['nombres'] ?? '',
        apellidos: map['apellidos'] ?? '',
        rol: map['rol'] ?? 'residente',
        estado: map['estado'] ?? 'activo',
        correo: map['correo'],
        celular: map['celular'],
        parentesco: map['parentesco'],
        vivienda: map['vivienda'] is Map 
          ? Vivienda.fromMap(map['vivienda']) 
          : Vivienda(manzana: '', villa: ''),
        fechaCreado: map['fechaCreado'] is String
          ? DateTime.parse(map['fechaCreado'])
          : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'firebaseUid': firebaseUid,
        'personaId': personaId,
        'identificacion': identificacion,
        'nombres': nombres,
        'apellidos': apellidos,
        'rol': rol,
        'estado': estado,
        'correo': correo,
        'celular': celular,
        'parentesco': parentesco,
        'vivienda': vivienda.toMap(),
        'fechaCreado': fechaCreado.toIso8601String(),
      };

  // Getter para compatibilidad
  String get nombreCompleto => '$nombres $apellidos';
}

class Vivienda {
  final String manzana;
  final String villa;

  Vivienda({required this.manzana, required this.villa});

  factory Vivienda.fromMap(Map<String, dynamic> map) => Vivienda(
        manzana: map['manzana'] ?? '',
        villa: map['villa'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'manzana': manzana,
        'villa': villa,
      };

  String get direccion => '$manzana-$villa';
}
