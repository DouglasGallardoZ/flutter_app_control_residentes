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

  factory Account.fromMap(Map<String, dynamic> m) => Account(
        uid: m['uid'] ?? '',
        id: m['id'] ?? '',
        role: m['role'] ?? 'resident',
        status: m['status'] ?? 'activo',
        email: m['email'],
        name: m['name'],
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
