import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/ports/account_repository.dart';
import 'prospecto_validation_event.dart';
import 'prospecto_validation_state.dart';

class ProspectoValidationBloc
    extends Bloc<ProspectoValidationEvent, ProspectoValidationState> {
  final AccountRepository repo;

  ProspectoValidationBloc(this.repo) : super(ProspectoValidationInitial()) {
    on<ValidarProspectoResidente>(_onValidarProspectoResidente);
    on<ValidarProspectoMiembro>(_onValidarProspectoMiembro);
    on<LimpiarValidacion>(_onLimpiarValidacion);
  }

  Future<void> _onValidarProspectoResidente(
    ValidarProspectoResidente event,
    Emitter<ProspectoValidationState> emit,
  ) async {
    emit(ProspectoValidationLoading());
    try {
      final prospecto = await repo.validarProspectoResidente(event.identificacion);
      emit(ProspectoResidenteValidado(prospecto));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(ProspectoValidationError(message));
    }
  }

  Future<void> _onValidarProspectoMiembro(
    ValidarProspectoMiembro event,
    Emitter<ProspectoValidationState> emit,
  ) async {
    emit(ProspectoValidationLoading());
    try {
      final prospecto = await repo.validarProspectoMiembro(event.identificacion);
      
      // Verificar si el miembro existe
      if (prospecto.existe && prospecto.personaEncontrada == true) {
        emit(ProspectoMiembroValidado(prospecto));
      } else {
        // Si no existe, emitir error para que se muestre el formulario de registro
        emit(ProspectoValidationError('Miembro no encontrado en el sistema'));
      }
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(ProspectoValidationError(message));
    }
  }

  Future<void> _onLimpiarValidacion(
    LimpiarValidacion event,
    Emitter<ProspectoValidationState> emit,
  ) async {
    emit(ProspectoValidationInitial());
  }
}
