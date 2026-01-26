abstract class ProspectoValidationEvent {}

class ValidarProspectoResidente extends ProspectoValidationEvent {
  final String identificacion;
  ValidarProspectoResidente(this.identificacion);
}

class ValidarProspectoMiembro extends ProspectoValidationEvent {
  final String identificacion;
  ValidarProspectoMiembro(this.identificacion);
}

class LimpiarValidacion extends ProspectoValidationEvent {}
