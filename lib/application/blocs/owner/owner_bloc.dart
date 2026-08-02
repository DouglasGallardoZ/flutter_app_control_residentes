import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/load_owners_by_location_usecase.dart';
import '../../../domain/usecases/block_owner_usecase.dart';
import '../../../domain/usecases/unblock_owner_usecase.dart';
import '../../../domain/usecases/delete_owner_usecase.dart';
import '../../../domain/usecases/get_owner_properties_usecase.dart';
import '../../../domain/usecases/create_owner_usecase.dart';
import '../../../domain/usecases/get_owner_with_spouses_usecase.dart';
import '../../../domain/usecases/create_spouse_usecase.dart';
import '../../../domain/usecases/delete_spouse_usecase.dart';
import '../../../domain/usecases/block_spouse_usecase.dart';
import '../../../domain/ports/owner_repository.dart';
import '../../../injection.dart';
import 'owner_event.dart';
import 'owner_state.dart';

class OwnerBloc extends Bloc<OwnerEvent, OwnerState> {
  final LoadOwnersByLocationUseCase loadOwnersByLocationUseCase;
  final BlockOwnerUseCase blockOwnerUseCase;
  final UnblockOwnerUseCase unblockOwnerUseCase;
  final DeleteOwnerUseCase deleteOwnerUseCase;
  final GetOwnerPropertiesUseCase getOwnerPropertiesUseCase;
  final CreateOwnerUseCase createOwnerUseCase;
  final GetOwnerWithSpousesUseCase getOwnerWithSpousesUseCase;
  final CreateSpouseUseCase createSpouseUseCase;
  final DeleteSpouseUseCase deleteSpouseUseCase;
  final BlockSpouseUseCase blockSpouseUseCase;

  OwnerBloc({
    required this.loadOwnersByLocationUseCase,
    required this.blockOwnerUseCase,
    required this.unblockOwnerUseCase,
    required this.deleteOwnerUseCase,
    required this.getOwnerPropertiesUseCase,
    required this.createOwnerUseCase,
    required this.getOwnerWithSpousesUseCase,
    required this.createSpouseUseCase,
    required this.deleteSpouseUseCase,
    required this.blockSpouseUseCase,
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
    on<LoadActiveOwners>(_onLoadActiveOwners);
    on<UpdateOwnerEvent>(_onUpdateOwner);
  }

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

  Future<void> _onBlockOwner(
    BlockOwnerEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await blockOwnerUseCase(event.ownerId, event.reason);
      emit(OwnerBlocked('Propietario bloqueado exitosamente', event.reason));
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

  Future<void> _onUnblockOwner(
    UnblockOwnerEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await unblockOwnerUseCase(event.ownerId, event.reason);
      emit(OwnerUnblocked(
          'Propietario desbloqueado exitosamente', event.reason));
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

  Future<void> _onDeleteOwner(
    DeleteOwnerEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await deleteOwnerUseCase(event.ownerId);
      emit(const OwnerDeleted('Propietario eliminado exitosamente'));
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
        fromChangeOwner: event.fromChangeOwner,
      );
      emit(OwnerCreated(
        message:
            response['mensaje'] ?? 'Propietario registrado exitosamente',
        owner: response,
      ));
    } catch (e) {
      emit(OwnerError(e.toString()));
    }
  }

  Future<void> _onLoadOwnerWithSpouses(
    LoadOwnerWithSpousesEvent event,
    Emitter<OwnerState> emit,
  ) async {
    emit(const OwnerLoading());
    try {
      final ownerWithSpouses =
          await getOwnerWithSpousesUseCase.execute(event.ownerId);
      emit(OwnerWithSpousesLoaded(ownerWithSpouses));
    } catch (e) {
      emit(OwnerError('Error al cargar propietario con cónyuges: $e'));
    }
  }

  Future<void> _onCreateSpouse(
    CreateSpouseEvent event,
    Emitter<OwnerState> emit,
  ) async {
    emit(const SpouseCreating());
    try {
      final spouse = await createSpouseUseCase.execute(
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
      add(LoadOwnerWithSpousesEvent(event.ownerId));
    } catch (e) {
      emit(SpouseError('Error al crear cónyuge: $e'));
    }
  }

  Future<void> _onDeleteSpouse(
    DeleteSpouseEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await deleteSpouseUseCase.execute(event.spouseId);
      emit(const SpouseDeleted('Cónyuge eliminado exitosamente'));
    } catch (e) {
      emit(SpouseError('Error al eliminar cónyuge: $e'));
    }
  }

  Future<void> _onBlockSpouse(
    BlockSpouseEvent event,
    Emitter<OwnerState> emit,
  ) async {
    try {
      await blockSpouseUseCase.execute(event.spouseId, event.block);
      emit(SpouseBlocked(
        event.block
            ? 'Cónyuge bloqueado exitosamente'
            : 'Cónyuge desbloqueado exitosamente',
        event.block,
      ));
    } catch (e) {
      emit(SpouseError(
          'Error al ${event.block ? 'bloquear' : 'desbloquear'} cónyuge: $e'));
    }
  }

  Future<void> _onLoadActiveOwners(
    LoadActiveOwners event,
    Emitter<OwnerState> emit,
  ) async {
    emit(const OwnersLoading());
    try {
      final owners = await loadOwnersByLocationUseCase(
        manzana: '', villa: '', page: 1, pageSize: 200);
      emit(OwnersLoaded(owners
          .map((o) => {
                'personaId': o.id,
                'nombres': o.nombre,
                'apellidos': o.apellido,
                'identificacion': o.identificacion,
              })
          .toList()));
    } catch (e) {
      emit(OwnerError(e.toString()));
    }
  }

  Future<void> _onUpdateOwner(
    UpdateOwnerEvent event,
    Emitter<OwnerState> emit,
  ) async {
    emit(const OwnerLoading());
    try {
      final repo = sl<OwnerRepository>();
      await repo.updateOwner(
        ownerId: event.ownerId,
        correo: event.correo,
        celular: event.celular,
      );
      emit(const OwnerUpdated(
          'Datos del propietario actualizados correctamente'));
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
}
