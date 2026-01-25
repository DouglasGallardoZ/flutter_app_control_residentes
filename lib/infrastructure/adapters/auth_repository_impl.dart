import '../../domain/ports/auth_repository.dart';
import '../providers/firebase_auth_provider.dart';
import '../dtos/perfil_usuario_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthProvider firebaseProvider;
  final ApiAuthProvider apiProvider;

  AuthRepositoryImpl({
    required this.firebaseProvider,
    required this.apiProvider,
  });

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Autenticar en Firebase
      final userCredential = await firebaseProvider.signInWithEmail(email, password);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Error en autenticación Firebase');
      }

      // 2. Obtener ID token de Firebase
      final idToken = await user.getIdToken(true);

      // 3. Obtener perfil desde API
      final perfilData = await apiProvider.obtenerPerfil(user.uid);
      final perfil = PerfilUsuarioDTO.fromJson(perfilData);

      // Construir respuesta de login
      final Map<String, dynamic> loginResponse = {
        'uid': user.uid,
        'email': user.email,
        'idToken': idToken,
        'nombres': perfil.nombres,
        'apellidos': perfil.apellidos,
        'rol': perfil.rol,
        'estado': perfil.estado,
      };

      // Agregar nombre completo para fácil acceso
      final nombres = perfil.nombres ?? '';
      final apellidos = perfil.apellidos ?? '';
      final fullName = '$nombres $apellidos'.trim();
      if (fullName.isNotEmpty) {
        loginResponse['name'] = fullName;
      }

      // Agregar campos opcionales solo si no es null
      if (perfil.personaId != null) {
        loginResponse['personaId'] = perfil.personaId;
      }
      
      if (perfil.identificacion != null) {
        loginResponse['identificacion'] = perfil.identificacion;
      }
      
      if (perfil.vivienda != null) {
        loginResponse['vivienda'] = perfil.vivienda!.toJson();
        // Agregar residence_id y residence para fácil acceso
        if (perfil.vivienda!.viviendaId != null) {
          loginResponse['residence_id'] = perfil.vivienda!.viviendaId;
        }
        // Construir residence string "Manzana X, Villa Y"
        final manzana = perfil.vivienda!.manzana ?? '';
        final villa = perfil.vivienda!.villa ?? '';
        if (manzana.isNotEmpty && villa.isNotEmpty) {
          loginResponse['residence'] = 'Manzana $manzana, Villa $villa';
        }
      }
      
      if (perfil.parentesco != null) {
        loginResponse['parentesco'] = perfil.parentesco;
      }

      return loginResponse;
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
