import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/validar_prospecto_residente_usecase.dart';
import '../../../domain/usecases/validar_prospecto_miembro_usecase.dart';
import 'prospecto_validation_event.dart';
import 'prospecto_validation_state.dart';

class ProspectoValidationBloc
    extends Bloc<ProspectoValidationEvent, ProspectoValidationState> {
  final ValidarProspectoResidenteUseCase validarResidente;
  final ValidarProspectoMiembroUseCase validarMiembro;

  ProspectoValidationBloc({
    required this.validarResidente,
    required this.validarMiembro,
  }) : super(ProspectoValidationInitial()) {
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
      final prospecto =
          await validarResidente.execute(event.identificacion);
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
      final prospecto = await validarMiembro.execute(event.identificacion);

      if (prospecto.existe) {
        emit(ProspectoMiembroValidado(prospecto));
      } else {
        emit(ProspectoValidationError(
            'Miembro no encontrado en el sistema'));
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
