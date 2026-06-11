import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/ports/biometrics/facial_verification_api_port.dart';
import 'facial_verification_event.dart';
import 'facial_verification_state.dart';

class FacialVerificationBloc
    extends Bloc<FacialVerificationEvent, FacialVerificationState> {
  final FacialVerificationApiPort verificationApi;

  FacialVerificationBloc({required this.verificationApi})
      : super(FacialVerificationInitial()) {
    on<VerifyFaceSubmitted>(_onVerifyFace);
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
}
