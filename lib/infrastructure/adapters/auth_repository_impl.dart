import '../../domain/ports/auth_repository.dart';
import '../../domain/ports/firebase_auth_provider_port.dart';
import '../../domain/ports/api_auth_provider_port.dart';
import '../dtos/perfil_usuario_dto.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthProviderPort firebaseProvider;
  final ApiAuthProviderPort apiProvider;

  AuthRepositoryImpl({
    required this.firebaseProvider,
    required this.apiProvider,
  });

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await firebaseProvider.signInWithEmail(email, password);
      final uid = credential.uid;

      final idToken = await firebaseProvider.getIdToken(forceRefresh: true);

      final perfilData = await apiProvider.obtenerPerfil(uid);
      final perfil = PerfilUsuarioDTO.fromJson(perfilData);
      final account = perfil.toEntity(uid);

      final session = AuthSession(
        uid: uid,
        email: credential.email ?? email,
        idToken: idToken,
        account: account,
        createdAt: DateTime.now(),
        expiresAt: null,
      );

      return session;
    } on Exception catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResult> signUpWithEmail(
      String email, String password) async {
    try {
      return await firebaseProvider.signUpWithEmail(email, password);
    } on Exception catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseProvider.logout();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Map<String, dynamic>? get currentUser {
    final credential = firebaseProvider.currentUser;
    if (credential != null) {
      return {
        'uid': credential.uid,
        'email': credential.email,
      };
    }
    return null;
  }

  @override
  Stream<Map<String, dynamic>?> get authStateChanges {
    return firebaseProvider.authStateChanges.map((credential) {
      if (credential != null) {
        return {
          'uid': credential.uid,
          'email': credential.email,
        };
      }
      return null;
    });
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await firebaseProvider.getIdToken(forceRefresh: forceRefresh);
  }
}
