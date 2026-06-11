import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/ports/firebase_auth_provider_port.dart';
import '../../../domain/ports/biometrics/facial_enrollment_api_port.dart';
import 'facial_enrollment_event.dart';
import 'facial_enrollment_state.dart';

class FacialEnrollmentBloc
    extends Bloc<FacialEnrollmentEvent, FacialEnrollmentState> {
  final FacialEnrollmentApiPort enrollmentApi;
  final FirebaseAuthProviderPort authProvider;

  String _personaId = '';
  bool _estaCapturando = false;
  List<Uint8List> _rutasPendientes = [];

  FacialEnrollmentBloc({
    required this.enrollmentApi,
    required this.authProvider,
  }) : super(const FacialEnrollmentInitial()) {
    on<EnrollmentStarted>(_onEnrollmentStarted);
    on<FaceCaptured>(_onFaceCaptured);
    on<EnrollmentSubmitted>(_onSubmit);
    on<EnrollmentResubmit>(_onResubmit);
    on<EnrollmentRetried>(_onRetry);
  }

  Future<void> _onEnrollmentStarted(
    EnrollmentStarted event,
    Emitter<FacialEnrollmentState> emit,
  ) async {
    _personaId = event.personaId;
    _rutasPendientes = [];
    emit(FacialEnrollmentInProgress.inicial());
  }

  Future<void> _onFaceCaptured(
    FaceCaptured event,
    Emitter<FacialEnrollmentState> emit,
  ) async {
    if (_estaCapturando) return;
    _estaCapturando = true;

    try {
      final current = state;
      if (current is! FacialEnrollmentInProgress) {
        return;
      }

      final bytes = event.bytes;
      final updated = current.conCaptura(event.angle, bytes);
      final fotoNumero = updated.fotosCapturadas;

      emit(FacialPhotoCaptured(
        fotoNumero: fotoNumero,
        rutaImagen: 'face_${event.angle.name}.jpg',
        angulo: event.angle,
      ));

      await Future.delayed(const Duration(milliseconds: 500));

      if (updated.completo) {
        _rutasPendientes = updated.rutasBytes;
        add(EnrollmentSubmitted(
          usuarioCreado: authProvider.currentUser?.email,
        ));
      } else {
        emit(updated);
      }
    } finally {
      _estaCapturando = false;
    }
  }

  Future<void> _onSubmit(
    EnrollmentSubmitted event,
    Emitter<FacialEnrollmentState> emit,
  ) async {
    await _enviarAlServidor(emit, event.usuarioCreado);
  }

  Future<void> _onResubmit(
    EnrollmentResubmit event,
    Emitter<FacialEnrollmentState> emit,
  ) async {
    await _enviarAlServidor(emit, null);
  }

  Future<void> _enviarAlServidor(
    Emitter<FacialEnrollmentState> emit,
    String? usuarioCreado,
  ) async {
    emit(const FacialEnrollmentSubmitting());

    if (_rutasPendientes.length < 3) {
      emit(FacialEnrollmentInProgress.inicial());
      return;
    }

    try {
      final usuario = usuarioCreado ?? 'flutter_app';

      final response = await enrollmentApi.enrollFacialData(
        personaId: _personaId,
        imagenesBytes: _rutasPendientes,
        usuarioCreado: usuario,
      );

      final mensaje = response['message'] ?? 'Registro facial exitoso';
      final enrollmentId = response['enrollment_id'] as String?;

      _rutasPendientes = [];
      emit(FacialEnrollmentSuccess(
        mensaje: mensaje,
        enrollmentId: enrollmentId,
      ));
    } on DioException catch (e) {
      emit(FacialEnrollmentError(mensaje: _extraerMensajeDio(e)));
    } catch (e) {
      final mensaje = _esErrorDeRed(e)
          ? 'Sin conexión a internet. Verifique su red e intente nuevamente.'
          : e.toString().replaceAll('Exception: ', '');
      emit(FacialEnrollmentError(mensaje: mensaje));
    }
  }

  bool _esErrorDeRed(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('network') ||
        msg.contains('host') ||
        msg.contains('timeout') ||
        msg.contains('refused');
  }

  String _extraerMensajeDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado. El servidor no responde. Intente nuevamente.';
      case DioExceptionType.sendTimeout:
        return 'Error al enviar los datos. Verifique su conexión.';
      case DioExceptionType.receiveTimeout:
        return 'El servidor tardó demasiado en responder. Intente nuevamente.';
      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor de biometría. Verifique su red.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return 'Sesión expirada. Inicie sesión nuevamente.';
        }
        if (statusCode == 413) {
          return 'Las imágenes son demasiado grandes. Reduzca la resolución.';
        }
        if (statusCode == 422) {
          final detail = _extraerDetail(e.response?.data);
          return detail ?? 'Datos inválidos. Verifique la información enviada.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'Error interno del servidor ($statusCode). Intente más tarde.';
        }
        return 'Error del servidor (${statusCode ?? 'desconocido'}). Intente nuevamente.';
      case DioExceptionType.cancel:
        return 'Operación cancelada.';
      case DioExceptionType.badCertificate:
        return 'Error de certificado SSL. Contacte al administrador.';
      case DioExceptionType.unknown:
      default:
        return 'Error de conexión. Verifique su conexión a internet.';
    }
  }

  String? _extraerDetail(dynamic data) {
    if (data is Map) {
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first.containsKey('msg')) {
            return first['msg'];
          }
        }
      }
      if (data.containsKey('message')) {
        return data['message']?.toString();
      }
    }
    return null;
  }

  Future<void> _onRetry(
    EnrollmentRetried event,
    Emitter<FacialEnrollmentState> emit,
  ) async {
    _rutasPendientes = [];
    emit(FacialEnrollmentInProgress.inicial());
  }
}
