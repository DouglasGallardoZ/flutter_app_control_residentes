import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/vivienda_entity.dart';
import '../../../domain/usecases/listar_viviendas_usecase.dart';
import '../../../domain/usecases/crear_vivienda_usecase.dart';
import '../../../domain/usecases/actualizar_vivienda_usecase.dart';
import '../../../domain/usecases/cambiar_estado_vivienda_usecase.dart';

part 'vivienda_event.dart';
part 'vivienda_state.dart';

class ViviendaBloc
    extends Bloc<ViviendaEvent,
        ViviendaState> {
  final ListarViviendasUseCase
      _listarUseCase;
  final CrearViviendaUseCase _crearUseCase;
  final ActualizarViviendaUseCase
      _actualizarUseCase;
  final CambiarEstadoViviendaUseCase
      _cambiarEstadoUseCase;

  String? _ultimaManzana;
  String? _ultimoEstado;
  int _paginaActual = 1;
  bool _hasNext = false;
  List<ViviendaEntity> _todas = [];

  ViviendaBloc({
    required ListarViviendasUseCase
        listarUseCase,
    required CrearViviendaUseCase
        crearUseCase,
    required ActualizarViviendaUseCase
        actualizarUseCase,
    required CambiarEstadoViviendaUseCase
        cambiarEstadoUseCase,
  })  : _listarUseCase =
            listarUseCase,
        _crearUseCase = crearUseCase,
        _actualizarUseCase =
            actualizarUseCase,
        _cambiarEstadoUseCase =
            cambiarEstadoUseCase,
        super(
            const ViviendaInitial()) {
    on<LoadViviendas>(_onLoad);
    on<LoadMoreViviendas>(_onLoadMore);
    on<CreateVivienda>(_onCreate);
    on<UpdateVivienda>(_onUpdate);
    on<ToggleViviendaEstado>(
        _onToggleEstado);
  }

  Future<void> _onLoad(
    LoadViviendas event,
    Emitter<ViviendaState> emit,
  ) async {
    _ultimaManzana = event.manzana;
    _ultimoEstado = event.estado;
    _paginaActual = 1;

    emit(const ViviendaLoading());
    try {
      _todas =
          await _listarUseCase.execute(
        page: 1,
        manzana: event.manzana,
        estado: event.estado,
      );
      _hasNext =
          _todas.length >= 20;
      emit(ViviendaLoaded(
        viviendas: _todas,
        hasNext: _hasNext,
      ));
    } catch (e) {
      emit(ViviendaError(
          mensaje: e
              .toString()
              .replaceAll(
                  'Exception: ',
                  '')));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreViviendas event,
    Emitter<ViviendaState> emit,
  ) async {
    if (!_hasNext) return;
    _paginaActual++;

    try {
      final nuevas =
          await _listarUseCase.execute(
        page: _paginaActual,
        manzana: _ultimaManzana,
        estado: _ultimoEstado,
      );
      _todas.addAll(nuevas);
      _hasNext =
          nuevas.length >= 20;
      emit(ViviendaLoaded(
        viviendas: List.from(_todas),
        hasNext: _hasNext,
      ));
    } catch (e) {
      emit(ViviendaError(
          mensaje: e
              .toString()
              .replaceAll(
                  'Exception: ',
                  '')));
    }
  }

  Future<void> _onCreate(
    CreateVivienda event,
    Emitter<ViviendaState> emit,
  ) async {
    emit(const ViviendaLoading());
    try {
      await _crearUseCase.execute(
        manzana: event.manzana,
        villa: event.villa,
      );
      emit(const ViviendaCreated());
      add(LoadViviendas(
          manzana: _ultimaManzana,
          estado: _ultimoEstado));
    } catch (e) {
      emit(ViviendaError(
          mensaje: e
              .toString()
              .replaceAll(
                  'Exception: ',
                  '')));
    }
  }

  Future<void> _onUpdate(
    UpdateVivienda event,
    Emitter<ViviendaState> emit,
  ) async {
    emit(const ViviendaLoading());
    try {
      await _actualizarUseCase.execute(
        viviendaId: event.viviendaId,
        manzana: event.manzana,
        villa: event.villa,
      );
      emit(const ViviendaUpdated());
      add(LoadViviendas(
          manzana: _ultimaManzana,
          estado: _ultimoEstado));
    } catch (e) {
      emit(ViviendaError(
          mensaje: e
              .toString()
              .replaceAll(
                  'Exception: ',
                  '')));
    }
  }

  Future<void> _onToggleEstado(
    ToggleViviendaEstado event,
    Emitter<ViviendaState> emit,
  ) async {
    emit(const ViviendaLoading());
    try {
      await _cambiarEstadoUseCase
          .execute(
        viviendaId: event.viviendaId,
        estado: event.estado,
        motivo: event.motivo,
      );
      emit(ViviendaEstadoChanged(
        viviendaId: event.viviendaId,
        nuevoEstado: event.estado,
        mensaje:
            event.estado == 'activo'
                ? 'Vivienda activada exitosamente'
                : 'Vivienda desactivada exitosamente',
      ));
      add(LoadViviendas(
          manzana: _ultimaManzana,
          estado: _ultimoEstado));
    } catch (e) {
      emit(ViviendaError(
          mensaje: e
              .toString()
              .replaceAll(
                  'Exception: ',
                  '')));
    }
  }
}
