import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/vivienda_entity.dart';
import '../../../domain/entities/villa_detalle_entity.dart';
import '../../../domain/usecases/listar_viviendas_usecase.dart';
import '../../../domain/usecases/crear_vivienda_usecase.dart';
import '../../../domain/usecases/actualizar_vivienda_usecase.dart';
import '../../../domain/usecases/cambiar_estado_vivienda_usecase.dart';
import '../../../domain/usecases/cambiar_propietario_vivienda_usecase.dart';
import '../../../domain/ports/vivienda_repository_port.dart';
import '../../../injection.dart';

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
  final CambiarPropietarioViviendaUseCase
      _cambiarPropietarioUseCase;

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
    required CambiarPropietarioViviendaUseCase
        cambiarPropietarioUseCase,
  })  : _listarUseCase =
            listarUseCase,
        _crearUseCase = crearUseCase,
        _actualizarUseCase =
            actualizarUseCase,
        _cambiarEstadoUseCase =
            cambiarEstadoUseCase,
        _cambiarPropietarioUseCase =
            cambiarPropietarioUseCase,
        super(
            const ViviendaInitial()) {
    on<LoadViviendas>(_onLoad);
    on<LoadMoreViviendas>(_onLoadMore);
    on<CreateVivienda>(_onCreate);
    on<UpdateVivienda>(_onUpdate);
    on<ToggleViviendaEstado>(_onToggleEstado);
    on<CreateBulkViviendas>(_onCreateBulk);
    on<LoadManzanas>(_onLoadManzanas);
    on<CambiarPropietario>(_onCambiarPropietario);
    on<LoadVillaDetalle>(_onLoadVillaDetalle);
  }

  Future<void> _onLoad(
    LoadViviendas event,
    Emitter<ViviendaState> emit,
  ) async {
    _ultimaManzana = event.manzana;
    _ultimoEstado = event.estado;
    _paginaActual = 1;

    if (state is! ViviendaLoaded) {
      emit(const ViviendaLoading());
    }
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

  Future<void> _onCreateBulk(
    CreateBulkViviendas event,
    Emitter<ViviendaState> emit,
  ) async {
    emit(const ViviendaLoading());
    final omitidas = <String>[];
    var creadas = 0;
    try {
      for (var i = 1; i <= event.cantidad; i++) {
        try {
          await _crearUseCase.execute(manzana: event.manzana, villa: '$i');
          creadas++;
        } catch (_) {
          omitidas.add('Villa $i');
        }
      }
      emit(ViviendasBulkCreated(creadas: creadas, omitidas: omitidas, manzana: event.manzana));
      add(const LoadManzanas());
    } catch (e) {
      emit(ViviendaError(mensaje: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadManzanas(
    LoadManzanas event,
    Emitter<ViviendaState> emit,
  ) async {
    if (state is! ManzanasLoaded) {
      emit(const ManzanasLoading());
    }
    try {
      final todas = await _listarUseCase.execute(page: 1, pageSize: 100);
      final grouped = <String, List<ViviendaEntity>>{};
      for (final v in todas) {
        grouped.putIfAbsent(v.manzana, () => []).add(v);
      }
      final resumen = grouped.entries.map((e) {
        final villas = e.value;
        final activas = villas.where((v) => v.estado == 'activo').length;
        return ManzanaResumen(
          manzana: e.key,
          totalVillas: villas.length,
          villasActivas: activas,
          villasInactivas: villas.length - activas,
          totalPropietarios: villas.fold(0, (s, v) => s + v.propietarios.length),
          totalResidentes: villas.fold(0, (s, v) => s + v.totalResidentes),
          totalMiembros: villas.fold(0, (s, v) => s + v.totalMiembros),
        );
      }).toList();
      emit(ManzanasLoaded(manzanas: resumen));
    } catch (e) {
      emit(ManzanasError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCambiarPropietario(
    CambiarPropietario event,
    Emitter<ViviendaState> emit,
  ) async {
    emit(const ViviendaLoading());
    try {
      await _cambiarPropietarioUseCase.execute(
        viviendaId: event.viviendaId,
        nuevoPropietarioId: event.nuevoPropietarioId,
        tipo: event.tipo,
        motivo: event.motivo,
      );
      emit(const PropietarioCambiado(
          mensaje: 'Propietario asignado correctamente'));
      add(LoadVillaDetalle(viviendaId: event.viviendaId));
    } catch (e) {
      final mensaje = e.toString().replaceAll('Exception: ', '');
      emit(ViviendaError(mensaje: mensaje));
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          add(LoadVillaDetalle(viviendaId: event.viviendaId));
        }
      });
    }
  }

  Future<void> _onLoadVillaDetalle(
    LoadVillaDetalle event,
    Emitter<ViviendaState> emit,
  ) async {
    emit(const ViviendaLoading());
    try {
      final port = sl<ViviendaRepositoryPort>();
      final detalle = await port.getVillaDetalle(event.viviendaId);
      emit(VillaDetalleLoaded(detalle: detalle));
    } catch (e) {
      emit(ViviendaError(mensaje: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
