import '../ports/account_repository.dart';
import '../entities/prospecto_residente.dart';

class CrearCuentaResidenteUseCase {
  final AccountRepository repository;
  CrearCuentaResidenteUseCase(this.repository);

  Future<CuentaResponse> execute({
    required int personaId,
    required String firebaseUid,
    required String username,
  }) async {
    return await repository.crearCuentaResidente(
      personaId: personaId,
      firebaseUid: firebaseUid,
      username: username,
    );
  }
}
