import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/manage_visitor_usecase.dart';
// import '../../../domain/entities/visitor.dart';
import 'visitor_event.dart';
import 'visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  final ManageVisitorUseCase usecase;
  
  VisitorBloc(this.usecase) : super(VisitorInitial()) {
    on<LoadVisitors>((e, emit) async {
      emit(VisitorLoading());
      try {
        final list = await usecase.list(e.residenceId);
        final helper = list.isEmpty
          ? 'No hay visitantes guardados. Cree el primero en "Nuevo Visitante".'
          : 'Seleccione un visitante o busque por nombre/identificación.';
        emit(VisitorLoaded(all: list, filtered: list, selected: null, helper: helper));
      } catch (_) {
        emit(VisitorError('Error al cargar visitantes'));
      }
    });

    on<LoadVisitantesVivienda>((e, emit) async {
      emit(VisitorLoading());
      try {
        final list = await usecase.getVisitantesVivienda();
        final helper = list.isEmpty
          ? 'No hay visitantes registrados para esta vivienda.'
          : 'Seleccione un visitante de la lista.';
        emit(VisitorLoaded(all: list, filtered: list, selected: null, helper: helper));
      } catch (_) {
        emit(VisitorError('Error al cargar visitantes'));
      }
    });

    on<SearchVisitors>((e, emit) {
      final st = state;
      if (st is VisitorLoaded) {
        final q = e.query.toLowerCase().trim();
        final filtered = st.all.where((v) => v.name.toLowerCase().contains(q) || v.id.contains(q)).toList();
        emit(st.copyWith(filtered: filtered));
      }
    });

    on<SelectVisitor>((e, emit) {
      final st = state;
      if (st is VisitorLoaded) emit(st.copyWith(selected: e.visitor));
    });

    on<UpsertVisitorRequested>((e, emit) async {
      try {
        final v = await usecase.registerOrUpdate(
          residenceId: e.residenceId, id: e.id, name: e.name, phone: e.phone, visitTime: e.visitTime,
        );
        emit(VisitorSuccess(v));
      } catch (_) {
        emit(VisitorError('No se pudo registrar/actualizar el visitante'));
      }
    });
  }
}

