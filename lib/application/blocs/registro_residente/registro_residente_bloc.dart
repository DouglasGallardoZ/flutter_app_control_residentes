import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/ports/account_repository.dart';
import '../../../domain/entities/prospecto_residente.dart';
import 'registro_residente_event.dart';
import 'registro_residente_state.dart';

class RegistroResidenteBloc
    extends Bloc<RegistroResidenteEvent, RegistroResidenteState> {
  final AccountRepository repo;

  RegistroResidenteBloc(this.repo) : super(RegistroResidenteInitial()) {
    on<RegistroResidenteIniciado>(_onRegistroIniciado);
    on<VerificacionFacialCapturada>(_onVerificacionFacialCapturada);
    on<VerificacionFacialCompleta>(_onVerificacionFacialCompleta);
    on<CredencialesIngresadas>(_onCredencialesIngresadas);
    on<CrearCuentaResidente>(_onCrearCuentaResidente);
    on<ResetRegistro>(_onResetRegistro);
  }

  Future<void> _onRegistroIniciado(
    RegistroResidenteIniciado event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    emit(RegistroResidenteEnProceso(event.prospecto));
  }

  Future<void> _onVerificacionFacialCapturada(
    VerificacionFacialCapturada event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    final state = this.state;
    if (state is RegistroResidenteEnProceso) {
      emit(VerificacionFacialEnProceso(state.prospecto));
    }
  }

  Future<void> _onVerificacionFacialCompleta(
    VerificacionFacialCompleta event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    final state = this.state;
    if (state is VerificacionFacialEnProceso) {
      if (event.esValida) {
        emit(VerificacionFacialExitosa(state.prospecto, event.distancia));
      } else {
        emit(VerificacionFacialFallida(
          state.prospecto,
          'La verificación facial no coincide. Intente nuevamente.',
          event.distancia,
        ));
      }
    }
  }

  Future<void> _onCredencialesIngresadas(
    CredencialesIngresadas event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    final state = this.state;
    if (state is VerificacionFacialExitosa) {
      emit(CredencialesEnProceso(state.prospecto));
    }
  }

  Future<void> _onCrearCuentaResidente(
    CrearCuentaResidente event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    try {
      final response = await repo.crearCuentaResidente(
        personaId: event.personaId,
        firebaseUid: event.firebaseUid,
        username: event.email,
      );
      emit(CuentaCreada(response));
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(RegistroResidenteError(message));
    }
  }

  Future<void> _onResetRegistro(
    ResetRegistro event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    emit(RegistroResidenteInitial());
  }
}
