import '../ports/account_repository.dart';
import '../entities/prospecto_residente.dart';

class ValidarProspectoMiembroUseCase {
  final AccountRepository repository;
  ValidarProspectoMiembroUseCase(this.repository);

  Future<ProspectoMiembro> execute(String identificacion) async {
    return await repository.validarProspectoMiembro(identificacion);
  }
}
