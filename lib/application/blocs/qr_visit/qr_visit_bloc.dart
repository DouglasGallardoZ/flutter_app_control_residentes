import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/generate_visit_qr_usecase.dart';
import 'qr_visit_event.dart';
import 'qr_visit_state.dart';

class QrVisitBloc extends Bloc<QrVisitEvent, QrVisitState> {
  final GenerateVisitQrUseCase usecase;
  QrVisitBloc(this.usecase) : super(QrVisitInitial()) {
    on<GenerateVisitQrRequested>((e, emit) async {
      emit(QrVisitLoading());
      try {
        final qr = await usecase(
          personaId: e.personaId,
          visitorId: e.visitorId,
          visitorName: e.visitorName,
          validFrom: e.validFrom,
          durationHours: e.durationHours,
        );
        emit(QrVisitReady(qr));
      } catch (_) {
        emit(QrVisitError('No se pudo generar el QR de visitante'));
      }
    });
  }
}
