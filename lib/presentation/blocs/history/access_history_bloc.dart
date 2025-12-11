import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/access_history_repository.dart';
import 'access_history_event.dart';
import 'access_history_state.dart';

class AccessHistoryBloc extends Bloc<AccessHistoryEvent, AccessHistoryState> {
  final AccessHistoryRepository repo;
  AccessHistoryBloc(this.repo) : super(AccessHistoryInitial()) {
    on<LoadAccessHistory>((e, emit) async {
      emit(AccessHistoryLoading());
      try {
        final logs = await repo.loadAccessLogs(accountId: e.accountId);
        emit(AccessHistoryLoaded(logs));
      } catch (_) {
        emit(AccessHistoryError('Error al cargar historial'));
      }
    });
  }
}
