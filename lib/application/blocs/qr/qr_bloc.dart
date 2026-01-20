import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/generate_qr_usecase.dart';
import 'qr_event.dart';
import 'qr_state.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  final GenerateQrUseCase usecase;
  QrBloc(this.usecase) : super(QrInitial()) {
    on<GenerateSelfQrConfigured>((e, emit) async {
      emit(QrLoading());
      try {
        final qr = await usecase.self(
          personaId: e.personaId,
          validFrom: e.validFrom,
          durationHours: e.durationHours,
          maxUses: e.maxUses,
        );
        emit(QrReady(qr));
      } catch (_) {
        emit(QrError('No se pudo generar el QR'));
      }
    });
  }
}
