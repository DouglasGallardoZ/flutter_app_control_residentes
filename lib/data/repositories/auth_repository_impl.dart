import '../../domain/repositories/auth_repository.dart';
import '../providers/firebase_auth_provider.dart';
import '../providers/firestore_provider.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthProvider auth;
  final FirestoreProvider db;
  AuthRepositoryImpl({required this.auth, required this.db});

  @override
  Future<Map<String, dynamic>> login({required String id, required String password}) async {
    // Buscar por identificación
    final snap = await db.db.collection('users').where('id', isEqualTo: id).limit(1).get();
    if (snap.docs.isEmpty) throw Exception('Error: propietario/residente/miembro no existe (CV-10)');
    final data = snap.docs.first.data();
    final email = data['email'] ?? '';
    if (email.isEmpty) throw Exception('Error: usuario sin correo asociado');

    // Auth por email/password
    await auth.signInWithEmail(email, password);

    // Estado de cuenta
    final status = data['status'] ?? 'activo';
    if (status == 'bloqueado') throw Exception('Error: cuenta bloqueada (CV-11)');
    if (status == 'eliminada') throw Exception('Error: cuenta eliminada (CV-12)');

    return {
      'id': id,
      'role': data['role'],
      'status': status,
      'email': email,
      'uid': data['uid'],
    };
  }

  @override
  Future<void> logout() => auth.signOut();
}
