import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_qr_list_usecase.dart';
import 'qr_list_event.dart';
import 'qr_list_state.dart';

class QrListBloc extends Bloc<QrListEvent, QrListState> {
  final GetQrListUseCase getQrListUseCase;

  QrListBloc({required this.getQrListUseCase}) : super(const QrListInitial()) {
    on<LoadQrList>(_onLoadQrList);
    on<FilterQrList>(_onFilterQrList);
    on<LoadMoreQrList>(_onLoadMoreQrList);
  }

  Future<void> _onLoadQrList(LoadQrList event, Emitter<QrListState> emit) async {
    emit(const QrListLoading());
    try {
      final response = await getQrListUseCase(
        page: event.page,
        pageSize: event.pageSize,
        tipoIngreso: event.tipoIngreso,
        usuarioId: event.usuarioId,
      );

      emit(QrListLoaded(
        qrs: response.qrs,
        total: response.total,
        currentPage: response.page,
        pageSize: response.pageSize,
        totalPages: response.totalPages,
        hasNext: response.hasNext,
        tipoIngreso: event.tipoIngreso,
      ));
    } catch (e) {
      emit(QrListError(message: 'Error al cargar QRs: $e'));
    }
  }

  Future<void> _onFilterQrList(FilterQrList event, Emitter<QrListState> emit) async {
    emit(const QrListLoading());
    try {
      final response = await getQrListUseCase(
        page: 1,
        pageSize: 10,
        tipoIngreso: event.tipoIngreso,
        usuarioId: event.usuarioId,
      );

      emit(QrListLoaded(
        qrs: response.qrs,
        total: response.total,
        currentPage: response.page,
        pageSize: response.pageSize,
        totalPages: response.totalPages,
        hasNext: response.hasNext,
        tipoIngreso: event.tipoIngreso,
      ));
    } catch (e) {
      emit(QrListError(message: 'Error al filtrar QRs: $e'));
    }
  }

  Future<void> _onLoadMoreQrList(LoadMoreQrList event, Emitter<QrListState> emit) async {
    if (state is! QrListLoaded) return;

    final currentState = state as QrListLoaded;
    if (!currentState.hasNext) return;

    try {
      final response = await getQrListUseCase(
        page: currentState.currentPage + 1,
        pageSize: currentState.pageSize,
        tipoIngreso: currentState.tipoIngreso,
        usuarioId: event.usuarioId,
      );

      emit(currentState.copyWith(
        qrs: [...currentState.qrs, ...response.qrs],
        currentPage: response.page,
        hasNext: response.hasNext,
      ));
    } catch (e) {
      emit(QrListError(message: 'Error al cargar más QRs: $e'));
    }
  }
}
