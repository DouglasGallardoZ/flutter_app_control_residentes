import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../infrastructure/providers/admin_api.dart';
import 'facial_enrollment_event.dart';
import 'facial_enrollment_state.dart';

class FacialEnrollmentBloc
    extends Bloc<FacialEnrollmentEvent, FacialEnrollmentState> {
  final AdminApi adminApi;

  List<String> _imagenesCapturadas = [];
  String _personaId = '';
  bool _estaCapturando = false;

  FacialEnrollmentBloc({required this.adminApi})
      : super(const FacialEnrollmentInitial()) {
    on<InitiateFacialEnrollment>(_onInitiate);
    on<FaceDetected>(_onFaceDetected);
    on<SubmitFacialEnrollment>(_onSubmit);
    on<RetryFacialEnrollment>(_onRetry);
  }

  /// Inicia el proceso de captura facial
  Future<void> _onInitiate(
    InitiateFacialEnrollment event,
    Emitter<FacialEnrollmentState> emit,
  ) async {
    _personaId = event.personaId;
    _imagenesCapturadas.clear();

    emit(const FacialEnrollmentInProgress(
      fotosCapturadas: 0,
      instruccion: 'MIRE AL FRENTE',
      fase: 'FRENTE',
    ));
  }

  /// Procesa detección de rostro y captura automática
  Future<void> _onFaceDetected(
    FaceDetected event,
    Emitter<FacialEnrollmentState> emit,
  ) async {
    if (_estaCapturando) return;
    _estaCapturando = true;

    try {
      // eulerAngleY está invertido: positivo = izquierda, negativo = derecha
      final angulo = event.eulerAngleY;
      bool debeCapturar = false;
      String? proximaFase;
      String? proximaInstruccion;

      // Lógica de detección de ángulo para determinar qué foto capturar
      if (_imagenesCapturadas.isEmpty) {
        // Primera foto: Mirando al frente (ángulo cercano a 0)
        if (angulo.abs() < 15) {
          debeCapturar = true;
          proximaFase = 'IZQUIERDA';
          proximaInstruccion = 'GIRE A LA IZQUIERDA';
        }
      } else if (_imagenesCapturadas.length == 1) {
        // Segunda foto: Mirando a la izquierda (ángulo positivo > 15)
        if (angulo > 15) {
          debeCapturar = true;
          proximaFase = 'DERECHA';
          proximaInstruccion = 'GIRE A LA DERECHA';
        }
      } else if (_imagenesCapturadas.length == 2) {
        // Tercera foto: Mirando a la derecha (ángulo negativo < -15)
        if (angulo < -15) {
          debeCapturar = true;
          proximaFase = null;
          proximaInstruccion = null;
        }
      }

      // Si no es el ángulo correcto, no capturar
      if (!debeCapturar) {
        _estaCapturando = false;
        return;
      }

      // Guardar imagen capturada
      _imagenesCapturadas.add(event.imagePath);
      
      print('✓ Foto ${_imagenesCapturadas.length} capturada - Ángulo: ${angulo.toStringAsFixed(2)}°');

      emit(FacialPhotoCaptured(
        fotoNumero: _imagenesCapturadas.length,
        rutaImagen: event.imagePath,
      ));

      // Pequeña pausa visual
      await Future.delayed(const Duration(milliseconds: 500));

      // Si tenemos las 3 fotos, enviar
      if (_imagenesCapturadas.length == 3) {
        print('✓ 3 fotos capturadas exitosamente. Enviando al servidor...');
        add(SubmitFacialEnrollment(imagenesRutas: _imagenesCapturadas));
      } else if (proximaInstruccion != null && proximaFase != null) {
        // Mostrar siguiente instrucción solo si existen
        emit(FacialEnrollmentInProgress(
          fotosCapturadas: _imagenesCapturadas.length,
          instruccion: proximaInstruccion,
          fase: proximaFase,
        ));
      }
    } finally {
      _estaCapturando = false;
    }
  }

  /// Envía datos de biometría al servidor
  Future<void> _onSubmit(
    SubmitFacialEnrollment event,
    Emitter<FacialEnrollmentState> emit,
  ) async {
    emit(const FacialEnrollmentSubmitting());

    try {
      final response = await adminApi.enrollFacialData(
        personaId: _personaId,
        imagenesRutas: event.imagenesRutas,
      );

      final mensaje = response['message'] ?? 'Registro facial exitoso';
      final enrollmentId = response['enrollment_id'] as String?;

      emit(FacialEnrollmentSuccess(
        mensaje: mensaje,
        enrollmentId: enrollmentId,
      ));
    } catch (e) {
      emit(FacialEnrollmentError(
        mensaje: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Reinicia el proceso de captura
  Future<void> _onRetry(
    RetryFacialEnrollment event,
    Emitter<FacialEnrollmentState> emit,
  ) async {
    _imagenesCapturadas.clear();

    emit(const FacialEnrollmentInProgress(
      fotosCapturadas: 0,
      instruccion: 'MIRE AL FRENTE',
      fase: 'FRENTE',
    ));
  }
}
