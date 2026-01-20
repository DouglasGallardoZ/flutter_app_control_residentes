import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/load_access_history_usecase.dart';
import 'access_history_event.dart';
import 'access_history_state.dart';

class AccessHistoryBloc extends Bloc<AccessHistoryEvent, AccessHistoryState> {
  final LoadAccessHistoryUseCase usecase;

  AccessHistoryBloc(this.usecase) : super(AccessHistoryInitial()) {
    on<LoadAccessHistory>((e, emit) async {
      emit(AccessHistoryLoading());
      try {
        final logs = await usecase(
          page: e.page ?? 1,
          pageSize: e.pageSize ?? 20,
        );
        emit(AccessHistoryLoaded(logs));
      } catch (ex) {
        emit(AccessHistoryError('Error al cargar historial: ${ex.toString()}'));
      }
    });
  }
}
