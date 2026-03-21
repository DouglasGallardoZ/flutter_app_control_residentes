import './account.dart';

/// Sesión de autenticación del usuario
class AuthSession {
  final String uid;
  final String email;
  final String? idToken;
  final Account account;
  final DateTime createdAt;
  final DateTime? expiresAt;

  AuthSession({
    required this.uid,
    required this.email,
    this.idToken,
    required this.account,
    required this.createdAt,
    this.expiresAt,
  });

  factory AuthSession.fromMap(Map<String, dynamic> map) {
    final account = Account.fromMap(map['account'] ?? {});
    return AuthSession(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      idToken: map['idToken'],
      account: account,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      expiresAt: map['expiresAt'] is String
          ? DateTime.tryParse(map['expiresAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'idToken': idToken,
      'account': account.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Verifica si la sesión ha expirado
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Obtiene el nombre completo del usuario
  String get nombreCompleto => account.nombreCompleto;

  /// Obtiene el rol del usuario
  String get rol => account.rol;

  /// Obtiene el estado del usuario
  String get estado => account.estado;

  /// Obtiene la vivienda del usuario
  Vivienda get vivienda => account.vivienda;

  @override
  String toString() => 'AuthSession(uid: $uid, email: $email, rol: $rol)';
}
