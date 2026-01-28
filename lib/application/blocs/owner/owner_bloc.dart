import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/load_owners_by_location_usecase.dart';
import '../../../domain/usecases/block_owner_usecase.dart';
import '../../../domain/usecases/unblock_owner_usecase.dart';
import '../../../domain/usecases/delete_owner_usecase.dart';
import '../../../domain/usecases/get_owner_properties_usecase.dart';
import '../../../domain/usecases/create_owner_usecase.dart';
import '../../../domain/ports/owner_repository.dart';
import 'owner_event.dart';
import 'owner_state.dart';

class OwnerBloc extends Bloc<OwnerEvent, OwnerState> {
  final LoadOwnersByLocationUseCase loadOwnersByLocationUseCase;
  final BlockOwnerUseCase blockOwnerUseCase;
  final UnblockOwnerUseCase unblockOwnerUseCase;
  final DeleteOwnerUseCase deleteOwnerUseCase;
  final GetOwnerPropertiesUseCase getOwnerPropertiesUseCase;
  final CreateOwnerUseCase createOwnerUseCase;
  final OwnerRepository ownerRepository;

  OwnerBloc({
    required this.loadOwnersByLocationUseCase,
    required this.blockOwnerUseCase,
    required this.unblockOwnerUseCase,
    required this.deleteOwnerUseCase,
    required this.getOwnerPropertiesUseCase,
    required this.createOwnerUseCase,
    required this.ownerRepository,
  }) : super(const OwnerInitial()) {
    on<LoadOwnersByLocationEvent>(_onLoadOwnersByLocation);
    on<BlockOwnerEvent>(_onBlockOwner);
    on<UnblockOwnerEvent>(_onUnblockOwner);
    on<DeleteOwnerEvent>(_onDeleteOwner);
    on<GetOwnerPropertiesEvent>(_onGetOwnerProperties);
    on<CreateOwnerEvent>(_onCreateOwner);
    on<LoadOwnerWithSpousesEvent>(_onLoadOwnerWithSpouses);
    on<CreateSpouseEvent>(_onCreateSpouse);
    on<DeleteSpouseEvent>(_onDeleteSpouse);
    on<BlockSpouseEvent>(_onBlockSpouse);
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

  /// Crear un nuevo propietario
  Future<void> _onCreateOwner(
    CreateOwnerEvent event,
    Emitter<OwnerState> emit,
  ) async {
    emit(const OwnerLoading());
    try {
      final response = await createOwnerUseCase(
        identificacion: event.identificacion,
        tipoIdentificacion: event.tipoIdentificacion,
        nombres: event.nombres,
        apellidos: event.apellidos,
        fechaNacimiento: event.fechaNacimiento,
        correo: event.correo,
        celular: event.celular,
        manzana: event.manzana,
        villa: event.villa,
        nacionalidad: event.nacionalidad,
        direccionAlternativa: event.direccionAlternativa,
        usuarioCreado: event.usuarioCreado,
      );
      emit(OwnerCreated(
        message: response['mensaje'] ?? 'Propietario registrado exitosamente',
        owner: response,
      ));
    } catch (e) {
      emit(OwnerError(e.toString()));
    }
  }

  // ========== Spouse Management Handlers ==========

  /// Cargar propietario con sus cónyuges
  Future<void> _onLoadOwnerWithSpouses(
    LoadOwnerWithSpousesEvent event,
    Emitter<OwnerState> emit,
  ) async {
    emit(const OwnerLoading());
    try {
      final ownerWithSpouses = await ownerRepository.getOwnerWithSpouses(event.ownerId);
      emit(OwnerWithSpousesLoaded(ownerWithSpouses));
    } catch (e) {
      emit(OwnerError('Error al cargar propietario con cónyuges: $e'));
    }
  }

  /// Crear un nuevo cónyuge
  Future<void> _onCreateSpouse(
    CreateSpouseEvent event,
    Emitter<OwnerState> emit,
  ) async {
    emit(const SpouseCreating());
    try {
      final spouse = await ownerRepository.createSpouse(
        ownerId: event.ownerId,
        tipoIdentificacion: event.tipoIdentificacion,
        identificacion: event.identificacion,
        nombre: event.nombre,
        apellido: event.apellido,
        fechaNacimiento: event.fechaNacimiento,
        nacionalidad: event.nacionalidad,
        correo: event.correo,
        celular: event.celular,
        direccionAlternativa: event.direccionAlternativa,
        usuarioCreado: event.usuarioCreado,
      );
      emit(SpouseCreated(spouse));
      // Recargar el propietario con cónyuges
      add(LoadOwnerWithSpousesEvent(event.ownerId));
    } catch (e) {
      emit(SpouseError('Error al crear cónyuge: $e'));
    }
  }

  /// Eliminar un cónyuge
  Future<void> _onDeleteSpouse(
    DeleteSpouseEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await ownerRepository.deleteSpouse(event.spouseId);
      emit(const SpouseDeleted('Cónyuge eliminado exitosamente'));
    } catch (e) {
      emit(SpouseError('Error al eliminar cónyuge: $e'));
    }
  }

  /// Bloquear o desbloquear un cónyuge
  Future<void> _onBlockSpouse(
    BlockSpouseEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await ownerRepository.blockSpouse(event.spouseId, event.block);
      emit(SpouseBlocked(
        event.block ? 'Cónyuge bloqueado exitosamente' : 'Cónyuge desbloqueado exitosamente',
        event.block,
      ));
    } catch (e) {
      emit(SpouseError('Error al ${event.block ? 'bloquear' : 'desbloquear'} cónyuge: $e'));
    }
  }
}
