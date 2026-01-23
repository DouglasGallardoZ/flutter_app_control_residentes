import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/load_owners_by_location_usecase.dart';
import '../../../domain/usecases/block_owner_usecase.dart';
import '../../../domain/usecases/unblock_owner_usecase.dart';
import '../../../domain/usecases/delete_owner_usecase.dart';
import '../../../domain/usecases/get_owner_properties_usecase.dart';
import 'owner_event.dart';
import 'owner_state.dart';

class OwnerBloc extends Bloc<OwnerEvent, OwnerState> {
  final LoadOwnersByLocationUseCase loadOwnersByLocationUseCase;
  final BlockOwnerUseCase blockOwnerUseCase;
  final UnblockOwnerUseCase unblockOwnerUseCase;
  final DeleteOwnerUseCase deleteOwnerUseCase;
  final GetOwnerPropertiesUseCase getOwnerPropertiesUseCase;

  OwnerBloc({
    required this.loadOwnersByLocationUseCase,
    required this.blockOwnerUseCase,
    required this.unblockOwnerUseCase,
    required this.deleteOwnerUseCase,
    required this.getOwnerPropertiesUseCase,
  }) : super(const OwnerInitial()) {
    on<LoadOwnersByLocationEvent>(_onLoadOwnersByLocation);
    on<BlockOwnerEvent>(_onBlockOwner);
    on<UnblockOwnerEvent>(_onUnblockOwner);
    on<DeleteOwnerEvent>(_onDeleteOwner);
    on<GetOwnerPropertiesEvent>(_onGetOwnerProperties);
  }

  /// Cargar propietarios por ubicación
  Future<void> _onLoadOwnersByLocation(
    LoadOwnersByLocationEvent event,
    Emitter<OwnerState> emit,
  ) async {
    emit(const OwnerLoading());
    try {
      final owners = await loadOwnersByLocationUseCase(
        manzana: event.manzana,
        villa: event.villa,
        page: event.page,
        pageSize: event.pageSize,
      );
      emit(OwnersByLocationLoaded(
        owners: owners,
        manzana: event.manzana,
        villa: event.villa,
        currentPage: event.page,
        hasMore: owners.length >= event.pageSize,
      ));
    } catch (e) {
      emit(OwnerError(e.toString()));
    }
  }

  /// Bloquear propietario
  Future<void> _onBlockOwner(
    BlockOwnerEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await blockOwnerUseCase(event.ownerId, event.reason);
      emit(OwnerBlocked('Propietario bloqueado exitosamente', event.reason));
      // Re-cargar la lista actual si está en modo ubicación
      if (state is OwnersByLocationLoaded) {
        final current = state as OwnersByLocationLoaded;
        add(LoadOwnersByLocationEvent(
          manzana: current.manzana,
          villa: current.villa,
          page: current.currentPage,
        ));
      }
    } catch (e) {
      emit(OwnerError(e.toString()));
    }
  }

  /// Desbloquear propietario
  Future<void> _onUnblockOwner(
    UnblockOwnerEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await unblockOwnerUseCase(event.ownerId, event.reason);
      emit(OwnerUnblocked('Propietario desbloqueado exitosamente', event.reason));
      // Re-cargar la lista actual si está en modo ubicación
      if (state is OwnersByLocationLoaded) {
        final current = state as OwnersByLocationLoaded;
        add(LoadOwnersByLocationEvent(
          manzana: current.manzana,
          villa: current.villa,
          page: current.currentPage,
        ));
      }
    } catch (e) {
      emit(OwnerError(e.toString()));
    }
  }

  /// Eliminar propietario
  Future<void> _onDeleteOwner(
    DeleteOwnerEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await deleteOwnerUseCase(event.ownerId);
      emit(const OwnerDeleted('Propietario eliminado exitosamente'));
      // Re-cargar la lista actual si está en modo ubicación
      if (state is OwnersByLocationLoaded) {
        final current = state as OwnersByLocationLoaded;
        add(LoadOwnersByLocationEvent(
          manzana: current.manzana,
          villa: current.villa,
          page: current.currentPage,
        ));
      }
    } catch (e) {
      emit(OwnerError(e.toString()));
    }
  }

  /// Obtener propiedades de un propietario
  Future<void> _onGetOwnerProperties(
    GetOwnerPropertiesEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      final properties = await getOwnerPropertiesUseCase(event.ownerId);
      emit(OwnerPropertiesLoaded(properties));
    } catch (e) {
      emit(OwnerError(e.toString()));
    }
  }
}
