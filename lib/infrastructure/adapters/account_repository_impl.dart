import '../../domain/ports/account_repository.dart';
import '../../domain/ports/api_auth_provider_port.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/prospecto_residente.dart';
import '../providers/family_members_api.dart';
import '../providers/account_api_provider.dart';
import '../dtos/perfil_usuario_dto.dart';

class AccountRepositoryImpl implements AccountRepository {
  final ApiAuthProviderPort apiProvider;
  final FamilyMembersApi familyMembersApi;
  final AccountApiProvider accountApiProvider;

  AccountRepositoryImpl(
    this.apiProvider,
    this.familyMembersApi,
    this.accountApiProvider,
  );

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
      return perfilDTO.toEntity(firebaseUid);
    } catch (e) {
      // Si no existe, retorna null
      if (e is Exception && e.toString().contains('404')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<Account>> listByResidenceAndRole(
      dynamic residenceId, String role) async {
    try {
      // Si residenceId es int, es vivienda_id - usar FamilyMembersApi
      if (residenceId is int) {
        final familyMembers =
            await familyMembersApi.obtenerMiembrosPorVivienda(residenceId);
        return familyMembers
            .map((member) => Account(
                  personaId: member.personaId,
                  firebaseUid: '',
                  identificacion: member.identificacion,
                  nombres: member.nombres,
                  apellidos: member.apellidos,
                  rol: 'miembro_familia',
                  estado: member.estado,
                  correo: member.correo,
                  celular: member.celular,
                  parentesco: member.parentesco,
                  fechaCreado: member.fechaCreado,
                  vivienda: Vivienda(
                    manzana: '',
                    villa: '',
                    viviendaId: residenceId,
                  ),
                ))
            .toList();
      }

      // Si es String (residencia), retorna lista vacía (método no implementado en backend)
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateEmail(String firebaseUid, String newEmail) async {
    try {
      // Esta operación se haría en Firebase Auth, no en la API
      throw UnimplementedError(
          'Usar FirebaseAuth directamente para actualizar email');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProspectoResidente> validarProspectoResidente(
      String identificacion) async {
    try {
      return await accountApiProvider.validarProspectoResidente(identificacion);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProspectoMiembro> validarProspectoMiembro(
      String identificacion) async {
    try {
      return await accountApiProvider.validarProspectoMiembro(identificacion);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CuentaResponse> crearCuentaResidente({
    required int personaId,
    required String firebaseUid,
    required String username,
  }) async {
    try {
      return await accountApiProvider.crearCuentaResidente(
        personaId: personaId,
        firebaseUid: firebaseUid,
        username: username,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CuentaResponse> crearCuentaMiembro({
    required int personaId,
    required String firebaseUid,
    required String username,
  }) async {
    try {
      return await accountApiProvider.crearCuentaMiembro(
        personaId: personaId,
        firebaseUid: firebaseUid,
        username: username,
      );
    } catch (e) {
      rethrow;
    }
  }
}
