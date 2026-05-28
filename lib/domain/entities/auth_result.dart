class AuthResult {
  final String uid;
  final String? email;

  const AuthResult({
    required this.uid,
    this.email,
  });

  factory AuthResult.fromMap(Map<String, dynamic> map) {
    return AuthResult(
      uid: map['uid'] as String,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
    };
  }

  @override
  String toString() => 'AuthResult(uid: $uid, email: $email)';
}
