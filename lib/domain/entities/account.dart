// lib/domain/entities/account.dart
class Account {
  final String uid;
  final String id; // identificación
  final String role; // admin | resident | family
  final String status; // activo | bloqueado | eliminada
  final String? email;
  final String? name;

  Account({
    required this.uid,
    required this.id,
    required this.role,
    required this.status,
    this.email,
    this.name,
  });

  factory Account.fromMap(Map<String, dynamic> map) => Account(
        uid: map['uid'] ?? '',
        id: map['id'] ?? '',
        role: map['role'] ?? 'resident',
        status: map['status'] ?? 'activo',
        email: map['email'],
        name: map['name'],
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'id': id,
        'role': role,
        'status': status,
        'email': email,
        'name': name,
      };
}
