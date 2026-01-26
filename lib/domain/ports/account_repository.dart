import '../entities/account.dart';
import '../entities/prospecto_residente.dart';

abstract class AccountRepository {
  Future<Account> register(Account account);
  Future<Account?> getById(String id);
  Future<void> updateEmail(String id, String newEmail);
  Future<List<Account>> listByResidenceAndRole(dynamic residenceId, String role);

  // Nuevos métodos para registro de cuentas
  Future<ProspectoResidente> validarProspectoResidente(String identificacion);
  Future<ProspectoMiembro> validarProspectoMiembro(String identificacion);
  Future<CuentaResponse> crearCuentaResidente({
    required int personaId,
    required String firebaseUid,
    required String username,
  });
  Future<CuentaResponse> crearCuentaMiembro({
    required int personaId,
    required String firebaseUid,
    required String username,
  });
}
