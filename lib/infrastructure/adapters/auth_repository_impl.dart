import '../../domain/ports/auth_repository.dart';
import '../../domain/ports/firebase_auth_provider_port.dart';
import '../../domain/ports/api_auth_provider_port.dart';
import '../dtos/perfil_usuario_dto.dart';
import '../../domain/entities/auth_session.dart';

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
      // 1. Autenticar en Firebase
      final userCredential =
          await firebaseProvider.signInWithEmail(email, password);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Error en autenticación Firebase');
      }

      // 2. Obtener ID token de Firebase
      final idToken = await user.getIdToken(true);

      // 3. Obtener perfil desde API
      final perfilData = await apiProvider.obtenerPerfil(user.uid);
      final perfil = PerfilUsuarioDTO.fromJson(perfilData);

      // 4. Convertir perfil a entidad Account
      final account = perfil.toEntity(user.uid);

      // 5. Crear sesión de autenticación
      final session = AuthSession(
        uid: user.uid,
        email: user.email ?? email,
        idToken: idToken,
        account: account,
        createdAt: DateTime.now(),
        expiresAt: null, // La expiración depende del token de Firebase
      );

      return session;
    } on Exception catch (e) {
      // Pasar el mensaje detallado del error
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      rethrow;
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
    final user = firebaseProvider.currentUser;
    if (user != null) {
      return {
        'uid': user.uid,
        'email': user.email,
      };
    }
    return null;
  }

  @override
  Stream<Map<String, dynamic>?> get authStateChanges {
    return firebaseProvider.authStateChanges.map((user) {
      if (user != null) {
        return {
          'uid': user.uid,
          'email': user.email,
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
