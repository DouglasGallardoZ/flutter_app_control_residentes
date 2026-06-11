import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/liveness_reto.dart';
import '../../../domain/ports/biometrics/facial_verification_api_port.dart';
import '../../../domain/usecases/generar_retos_liveness_usecase.dart';
import 'facial_verification_event.dart';
import 'facial_verification_state.dart';

class FacialVerificationBloc
    extends Bloc<FacialVerificationEvent, FacialVerificationState> {
  final FacialVerificationApiPort verificationApi;
  final GenerarRetosLivenessUseCase generarRetos;

  List<LivenessReto> _retos = [];
  int _indiceRetoActual = 0;
  Timer? _temporizadorReto;

  static const _duracionRetoSegundos = 5;

  FacialVerificationBloc({
    required this.verificationApi,
    required this.generarRetos,
  }) : super(FacialVerificationInitial()) {
    on<VerifyFaceSubmitted>(_onVerifyFace);
    on<IniciarVerificacionLiveness>(_onIniciarVerificacionLiveness);
    on<ProcesarFrameCamara>(_onProcesarFrameCamara);
    on<RetoTiempoExpirado>(_onRetoTiempoExpirado);
  }

  Future<void> _onVerifyFace(
    VerifyFaceSubmitted event,
    Emitter<FacialVerificationState> emit,
  ) async {
    emit(FacialVerificationLoading());
    try {
      final response = await verificationApi.verificarFacial(
        personaId: event.personaId,
        fotoBytes: event.fotoBytes,
      );

      final match = response['match'] as bool? ?? false;
      final distance =
          (response['distance'] as num?)?.toDouble() ?? 1.0;

      emit(FacialVerificationSuccess(match: match, distance: distance));
    } catch (e) {
      emit(FacialVerificationFailure(
          mensaje: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onIniciarVerificacionLiveness(
    IniciarVerificacionLiveness event,
    Emitter<FacialVerificationState> emit,
  ) async {
    _retos = generarRetos.execute();
    _indiceRetoActual = 0;

    if (_retos.isEmpty) {
      emit(LivenessExitoCaptura());
      return;
    }

    _presentarRetoActual(emit);
  }

  void _presentarRetoActual(Emitter<FacialVerificationState> emit) {
    _cancelarTemporizador();

    if (_indiceRetoActual >= _retos.length) {
      emit(LivenessExitoCaptura());
      return;
    }

    final reto = _retos[_indiceRetoActual];

    emit(LivenessRetoPresentado(
      retoActual: reto,
      indiceReto: _indiceRetoActual,
      totalRetos: _retos.length,
      segundosRestantes: _duracionRetoSegundos,
    ));

    _iniciarTemporizador();
  }

  void _iniciarTemporizador() {
    _temporizadorReto = Timer(
      const Duration(seconds: _duracionRetoSegundos),
      () => add(RetoTiempoExpirado()),
    );
  }

  void _cancelarTemporizador() {
    _temporizadorReto?.cancel();
    _temporizadorReto = null;
  }

  Future<void> _onProcesarFrameCamara(
    ProcesarFrameCamara event,
    Emitter<FacialVerificationState> emit,
  ) async {
    if (_indiceRetoActual >= _retos.length) return;

    final reto = _retos[_indiceRetoActual];

    final cumplido = _evaluarReto(reto, event);
    if (!cumplido) return;

    _indiceRetoActual++;
    _presentarRetoActual(emit);
  }

  bool _evaluarReto(LivenessReto reto, ProcesarFrameCamara frame) {
    switch (reto) {
      case LivenessReto.frente:
        return frame.eulerY.abs() < 15;
      case LivenessReto.izquierda:
        return frame.eulerY > 20;
      case LivenessReto.derecha:
        return frame.eulerY < -20;
      case LivenessReto.sonreir:
        return frame.smilingProb > 0.7;
    }
  }

  Future<void> _onRetoTiempoExpirado(
    RetoTiempoExpirado event,
    Emitter<FacialVerificationState> emit,
  ) async {
    _cancelarTemporizador();
    emit(LivenessErrorTimeout(
      mensaje: 'Tiempo expirado. Intente de nuevo.',
    ));
  }

  @override
  Future<void> close() {
    _cancelarTemporizador();
    return super.close();
  }
}
