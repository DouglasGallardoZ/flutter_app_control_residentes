import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/load_members_by_location_usecase.dart';
import '../../../domain/usecases/deactivate_member_usecase.dart';
import '../../../domain/usecases/reactivate_member_usecase.dart';
import '../../../domain/usecases/delete_member_usecase.dart';
import '../../../domain/usecases/create_member_usecase.dart';
import '../../../domain/ports/member_repository.dart';
import 'member_event.dart';
import 'member_state.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final LoadMembersByLocationUseCase loadMembersByLocationUseCase;
  final DeactivateMemberUseCase deactivateMemberUseCase;
  final ReactivateMemberUseCase reactivateMemberUseCase;
  final DeleteMemberUseCase deleteMemberUseCase;
  final CreateMemberUseCase createMemberUseCase;
  final MemberRepository memberRepository;

  MemberBloc({
    required this.loadMembersByLocationUseCase,
    required this.deactivateMemberUseCase,
    required this.reactivateMemberUseCase,
    required this.deleteMemberUseCase,
    required this.createMemberUseCase,
    required this.memberRepository,
  }) : super(const MemberInitial()) {
    on<LoadMembersByLocationEvent>(_onLoadMembersByLocation);
    on<DeactivateMemberEvent>(_onDeactivateMember);
    on<ReactivateMemberEvent>(_onReactivateMember);
    on<BloquearMiembroEvent>(_onBloquearMiembro);
    on<DesbloquearMiembroEvent>(_onDesbloquearMiembro);
    on<DeleteMemberEvent>(_onDeleteMember);
    on<CreateMemberEvent>(_onCreateMember);
  }

  /// Cargar miembros por ubicación
  Future<void> _onLoadMembersByLocation(
    LoadMembersByLocationEvent event,
    Emitter<MemberState> emit,
  ) async {
    emit(const MemberLoading());
    try {
      final members = await loadMembersByLocationUseCase(
        manzana: event.manzana,
        villa: event.villa,
      );
      emit(MembersByLocationLoaded(
        members: members,
        manzana: event.manzana,
        villa: event.villa,
      ));
    } catch (e) {
      emit(MemberError(message: 'Error al cargar miembros: $e'));
    }
  }

  /// Desactivar un miembro
  Future<void> _onDeactivateMember(
    DeactivateMemberEvent event,
    Emitter<MemberState> emit,
  ) async {
    try {
      await deactivateMemberUseCase(event.memberId, event.reason);
      emit(MemberDeactivated(
        message: 'Miembro desactivado correctamente',
        reason: event.reason,
      ));
      // Auto-refresh: si tenemos una búsqueda activa, recargar
      if (state is MembersByLocationLoaded) {
        final currentState = state as MembersByLocationLoaded;
        add(LoadMembersByLocationEvent(
          manzana: currentState.manzana,
          villa: currentState.villa,
        ));
      }
    } catch (e) {
      emit(MemberError(message: 'Error al desactivar miembro: $e'));
    }
  }

  /// Reactivar un miembro
  Future<void> _onReactivateMember(
    ReactivateMemberEvent event,
    Emitter<MemberState> emit,
  ) async {
    try {
      await reactivateMemberUseCase(event.memberId, event.reason);
      emit(MemberReactivated(
        message: 'Miembro reactivado correctamente',
        reason: event.reason,
      ));
      // Auto-refresh: si tenemos una búsqueda activa, recargar
      if (state is MembersByLocationLoaded) {
        final currentState = state as MembersByLocationLoaded;
        add(LoadMembersByLocationEvent(
          manzana: currentState.manzana,
          villa: currentState.villa,
        ));
      }
    } catch (e) {
      emit(MemberError(message: 'Error al reactivar miembro: $e'));
    }
  }

  Future<void> _onBloquearMiembro(
    BloquearMiembroEvent event,
    Emitter<MemberState> emit,
  ) async {
    try {
      await memberRepository.bloquearMiembro(
          memberId: event.memberId, reason: event.reason);
      emit(MemberDeactivated(
        message: 'Miembro bloqueado correctamente',
        reason: event.reason,
      ));
      if (state is MembersByLocationLoaded) {
        final currentState = state as MembersByLocationLoaded;
        add(LoadMembersByLocationEvent(
          manzana: currentState.manzana,
          villa: currentState.villa,
        ));
      }
    } catch (e) {
      emit(MemberError(message: 'Error al bloquear miembro: $e'));
    }
  }

  Future<void> _onDesbloquearMiembro(
    DesbloquearMiembroEvent event,
    Emitter<MemberState> emit,
  ) async {
    try {
      await memberRepository.desbloquearMiembro(
          memberId: event.memberId, reason: event.reason);
      emit(MemberReactivated(
        message: 'Miembro desbloqueado correctamente',
        reason: event.reason,
      ));
      if (state is MembersByLocationLoaded) {
        final currentState = state as MembersByLocationLoaded;
        add(LoadMembersByLocationEvent(
          manzana: currentState.manzana,
          villa: currentState.villa,
        ));
      }
    } catch (e) {
      emit(MemberError(message: 'Error al desbloquear miembro: $e'));
    }
  }

  /// Eliminar un miembro
  Future<void> _onDeleteMember(
    DeleteMemberEvent event,
    Emitter<MemberState> emit,
  ) async {
    try {
      await deleteMemberUseCase(event.memberId, event.motivo);
      emit(MemberDeleted(message: 'Miembro eliminado correctamente'));
      // Auto-refresh: si tenemos una búsqueda activa, recargar
      if (state is MembersByLocationLoaded) {
        final currentState = state as MembersByLocationLoaded;
        add(LoadMembersByLocationEvent(
          manzana: currentState.manzana,
          villa: currentState.villa,
        ));
      }
    } catch (e) {
      emit(MemberError(message: 'Error al eliminar miembro: $e'));
    }
  }

  /// Crear/agregar un nuevo miembro de familia
  Future<void> _onCreateMember(
    CreateMemberEvent event,
    Emitter<MemberState> emit,
  ) async {
    emit(const MemberLoading());
    try {
      final response = await createMemberUseCase(
        residenteId: event.residenteId,
        identificacion: event.identificacion,
        tipoIdentificacion: event.tipoIdentificacion,
        nombres: event.nombres,
        apellidos: event.apellidos,
        fechaNacimiento: event.fechaNacimiento,
        manzana: event.manzana,
        villa: event.villa,
        parentesco: event.parentesco,
        nacionalidad: event.nacionalidad,
        correo: event.correo,
        celular: event.celular,
        direccionAlternativa: event.direccionAlternativa,
        parentescoOtroDesc: event.parentescoOtroDesc,
        usuarioCreado: event.usuarioCreado,
      );
      emit(MemberCreated(
        message: response['mensaje'] ?? 'Miembro de familia agregado exitosamente',
        member: response,
      ));
    } catch (e) {
      emit(MemberError(message: 'Error al crear miembro: $e'));
    }
  }
}
