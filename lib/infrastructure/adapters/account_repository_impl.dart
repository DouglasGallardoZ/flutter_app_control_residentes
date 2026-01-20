import '../../domain/ports/account_repository.dart';
import '../../domain/entities/account.dart';
import '../providers/firebase_auth_provider.dart';
import '../dtos/perfil_usuario_dto.dart';

class AccountRepositoryImpl implements AccountRepository {
  final ApiAuthProvider apiProvider;

  AccountRepositoryImpl(this.apiProvider);

  @override
  Future<Account> register(Account account) async {
    try {
      // El registro se hace via Firebase + API endpoint POST /cuentas/residente/firebase
      // Este método es llamado después de la autenticación
      await apiProvider.crearCuentaResidente(
        personaId: account.personaId,
        firebaseUid: account.firebaseUid,
        email: account.correo ?? '',
      );
      return account;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Account?> getById(String firebaseUid) async {
    try {
      final response = await apiProvider.obtenerPerfil(firebaseUid);
      final perfilDTO = PerfilUsuarioDTO.fromJson(response);
      
      return Account(
        firebaseUid: firebaseUid,
        personaId: perfilDTO.personaId,
        identificacion: perfilDTO.identificacion,
        nombres: perfilDTO.nombres,
        apellidos: perfilDTO.apellidos,
        rol: perfilDTO.rol,
        estado: perfilDTO.estado,
        correo: perfilDTO.correo,
        celular: perfilDTO.celular,
        vivienda: Vivienda(
          manzana: perfilDTO.vivienda.manzana,
          villa: perfilDTO.vivienda.villa,
        ),
        parentesco: perfilDTO.parentesco,
        fechaCreado: perfilDTO.fechaCreado,
      );
    } catch (e) {
      // Si no existe, retorna null
      if (e is Exception && e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<Account>> listByResidenceAndRole(String residenceId, String role) async {
    try {
      // Este endpoint podría no existir en la API actual
      // Por ahora retorna lista vacía - necesitaría implementar en backend
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateEmail(String firebaseUid, String newEmail) async {
    try {
      // Esta operación se haría en Firebase Auth, no en la API
      throw UnimplementedError('Usar FirebaseAuth directamente para actualizar email');
    } catch (e) {
      rethrow;
    }
  }
}
