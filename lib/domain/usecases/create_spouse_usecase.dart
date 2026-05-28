import '../ports/owner_repository.dart';
import '../entities/conyuge_entity.dart';

class CreateSpouseUseCase {
  final OwnerRepository repository;
  CreateSpouseUseCase(this.repository);

  Future<ConyugeEntity> execute({
    required int ownerId,
    required String tipoIdentificacion,
    required String identificacion,
    required String nombre,
    required String apellido,
    required String fechaNacimiento,
    required String nacionalidad,
    required String correo,
    required String celular,
    String? direccionAlternativa,
    required String usuarioCreado,
  }) async {
    return await repository.createSpouse(
      ownerId: ownerId,
      tipoIdentificacion: tipoIdentificacion,
      identificacion: identificacion,
      nombre: nombre,
      apellido: apellido,
      fechaNacimiento: fechaNacimiento,
      nacionalidad: nacionalidad,
      correo: correo,
      celular: celular,
      direccionAlternativa: direccionAlternativa,
      usuarioCreado: usuarioCreado,
    );
  }
}
