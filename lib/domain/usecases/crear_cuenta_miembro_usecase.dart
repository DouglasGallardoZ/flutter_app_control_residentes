import '../ports/account_repository.dart';
import '../entities/prospecto_residente.dart';

class CrearCuentaMiembroUseCase {
  final AccountRepository repository;
  CrearCuentaMiembroUseCase(this.repository);

  Future<CuentaResponse> execute({
    required int personaId,
    required String firebaseUid,
    required String username,
  }) async {
    return await repository.crearCuentaMiembro(
      personaId: personaId,
      firebaseUid: firebaseUid,
      username: username,
    );
  }
}
