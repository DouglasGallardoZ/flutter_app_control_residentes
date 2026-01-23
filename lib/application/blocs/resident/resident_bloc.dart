import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_resident_usecase.dart';
import '../../../domain/ports/resident_repository.dart';
import 'resident_event.dart';
import 'resident_state.dart';

class ResidentBloc extends Bloc<ResidentEvent, ResidentState> {
  final CreateResidentUseCase createResidentUseCase;
  final ResidentRepository residentRepository;

  ResidentBloc({
    required this.createResidentUseCase,
    required this.residentRepository,
  }) : super(const ResidentInitial()) {
    on<CreateResidentEvent>(_onCreateResident);
    on<LoadResidentsEvent>(_onLoadResidents);
    // on<GetResidentEvent>(_onGetResident);
    on<DeactivateResidentEvent>(_onDeactivateResident);
  }

  /// Crear nuevo residente
  Future<void> _onCreateResident(
    CreateResidentEvent event,
    Emitter<ResidentState> emit,
  ) async {
    emit(const ResidentLoading());
    try {
      final response = await createResidentUseCase(
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
        docAutorizacionPdf: event.docAutorizacionPdf,
        usuarioCreado: event.usuarioCreado,
      );
      
      emit(ResidentCreated(
        resident: response,
        message: 'Residente registrado correctamente',
      ));
    } catch (e) {
      emit(ResidentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Cargar lista de residentes
  Future<void> _onLoadResidents(
    LoadResidentsEvent event,
    Emitter<ResidentState> emit,
  ) async {
    emit(const ResidentLoading());
    try {
      final residents = await residentRepository.getResidents();
      emit(ResidentsLoaded(residents));
    } catch (e) {
      emit(ResidentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Obtener residente específico
  // Future<void> _onGetResident(
  //   GetResidentEvent event,
  //   Emitter<ResidentState> emit,
  // ) async {
  //   emit(const ResidentLoading());
  //   try {
  //     final resident = await residentRepository.getResidentById(event.personaId);
  //     emit(ResidentLoaded(resident));
  //   } catch (e) {
  //     emit(ResidentError(
  //       e.toString().replaceAll('Exception: ', ''),
  //     ));
  //   }
  // }

  /// Desactivar residente
  Future<void> _onDeactivateResident(
    DeactivateResidentEvent event,
    Emitter<ResidentState> emit,
  ) async {
    emit(const ResidentLoading());
    try {
      await residentRepository.deactivateResident(
        personaId: event.personaId,
        reason: event.reason,
      );
      emit(const ResidentDeactivated('Residente desactivado correctamente'));
    } catch (e) {
      emit(ResidentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
