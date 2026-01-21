import '../../domain/ports/account_repository.dart';
import '../../domain/entities/account.dart';
import '../providers/firebase_auth_provider.dart';
import '../providers/family_members_api.dart';
import '../dtos/perfil_usuario_dto.dart';

class AccountRepositoryImpl implements AccountRepository {
  final ApiAuthProvider apiProvider;
  final FamilyMembersApi familyMembersApi;

  AccountRepositoryImpl(this.apiProvider, this.familyMembersApi);

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
      
      // Usar valores por defecto si son null (típico para admins)
      final vivienda = perfilDTO.vivienda ?? ViviendaDTO(
        viviendaId: null,
        manzana: '',
        villa: '',
      );
      
      return Account(
        firebaseUid: firebaseUid,
        personaId: perfilDTO.personaId ?? 0,
        identificacion: perfilDTO.identificacion ?? '',
        nombres: perfilDTO.nombres,
        apellidos: perfilDTO.apellidos,
        rol: perfilDTO.rol,
        estado: perfilDTO.estado,
        correo: perfilDTO.correo,
        celular: perfilDTO.celular,
        vivienda: Vivienda(
          manzana: vivienda.manzana,
          villa: vivienda.villa,
          viviendaId: vivienda.viviendaId ?? 0,
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
  Future<List<Account>> listByResidenceAndRole(dynamic residenceId, String role) async {
    try {
      // Si residenceId es int, es vivienda_id - usar FamilyMembersApi
      if (residenceId is int) {
        final familyMembers = await familyMembersApi.obtenerMiembrosPorVivienda(residenceId);
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
      throw UnimplementedError('Usar FirebaseAuth directamente para actualizar email');
    } catch (e) {
      rethrow;
    }
  }
}
