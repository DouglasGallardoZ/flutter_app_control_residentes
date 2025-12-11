import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/qr_repository.dart';
import '../../../domain/entities/visitor.dart';
import 'qr_event.dart';
import 'qr_state.dart';

class QrBloc extends Bloc<QrEvent, QrState> {
  final QrRepository repo;
  QrBloc(this.repo) : super(QrInitial()) {
    on<GenerateSelfQr>((e, emit) async {
      emit(QrLoading());
      try { final qr = await repo.generateSelf(accountId: e.accountId, params: e.params); emit(QrReady(qr)); }
      catch (ex) { emit(QrError('Error al generar QR')); }
    });
    on<GenerateVisitQr>((e, emit) async {
      emit(QrLoading());
      try {
        final qr = await repo.generateVisit(
          accountId: e.accountId,
          visitor: Visitor(name: e.visitorName, id: e.visitorId),
          params: e.params,
        );
        emit(QrReady(qr));
      } catch (ex) { emit(QrError('Error al generar QR de visita')); }
    });
  }
}
