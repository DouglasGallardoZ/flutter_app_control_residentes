import '../../domain/ports/auth_repository.dart';
import '../providers/firebase_auth_provider.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthProvider provider;
  AuthRepositoryImpl(this.provider);

  @override
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final cred = await provider.auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    return {'uid': user.uid, 'email': user.email};
  }

  @override
  Future<void> logout() => provider.auth.signOut();

  @override
  Map<String, dynamic>? get currentUser {
    final u = provider.auth.currentUser;
    return u == null ? null : {'uid': u.uid, 'email': u.email};
  }
}
