import '../ports/account_repository.dart';
import '../entities/prospecto_residente.dart';

class ValidarProspectoResidenteUseCase {
  final AccountRepository repository;
  ValidarProspectoResidenteUseCase(this.repository);

  Future<ProspectoResidente> execute(String identificacion) async {
    return await repository.validarProspectoResidente(identificacion);
  }
}
