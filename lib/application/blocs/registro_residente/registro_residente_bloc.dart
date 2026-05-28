import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/crear_cuenta_residente_usecase.dart';
import '../../../domain/usecases/crear_cuenta_miembro_usecase.dart';
import 'registro_residente_event.dart';
import 'registro_residente_state.dart';

class RegistroResidenteBloc
    extends Bloc<RegistroResidenteEvent, RegistroResidenteState> {
  final CrearCuentaResidenteUseCase crearCuentaResidente;
  final CrearCuentaMiembroUseCase crearCuentaMiembro;

  RegistroResidenteBloc({
    required this.crearCuentaResidente,
    required this.crearCuentaMiembro,
  }) : super(RegistroResidenteInitial()) {
    on<RegistroResidenteIniciado>(_onRegistroIniciado);
    on<VerificacionFacialCapturada>(_onVerificacionFacialCapturada);
    on<VerificacionFacialCompleta>(_onVerificacionFacialCompleta);
    on<CredencialesIngresadas>(_onCredencialesIngresadas);
    on<CrearCuentaResidente>(_onCrearCuentaResidente);
    on<CrearCuentaMiembro>(_onCrearCuentaMiembro);
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
      final response = await crearCuentaResidente.execute(
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

  Future<void> _onCrearCuentaMiembro(
    CrearCuentaMiembro event,
    Emitter<RegistroResidenteState> emit,
  ) async {
    try {
      final response = await crearCuentaMiembro.execute(
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
