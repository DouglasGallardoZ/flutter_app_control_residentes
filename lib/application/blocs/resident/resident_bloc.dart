import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_resident_usecase.dart';
import '../../../domain/usecases/load_residents_by_location_usecase.dart';
import '../../../domain/usecases/deactivate_resident_usecase.dart';
import '../../../domain/usecases/reactivate_resident_usecase.dart';
import '../../../domain/usecases/delete_resident_usecase.dart';
import '../../../domain/usecases/get_residence_accesses_usecase.dart';
import '../../../domain/usecases/load_residents_usecase.dart';
import 'resident_event.dart';
import 'resident_state.dart';

class ResidentBloc extends Bloc<ResidentEvent, ResidentState> {
  final CreateResidentUseCase createResidentUseCase;
  final LoadResidentsByLocationUseCase loadResidentsByLocationUseCase;
  final DeactivateResidentUseCase deactivateResidentUseCase;
  final ReactivateResidentUseCase reactivateResidentUseCase;
  final DeleteResidentUseCase deleteResidentUseCase;
  final GetResidenceAccessesUseCase getResidenceAccessesUseCase;
  final LoadResidentsUseCase loadResidentsUseCase;

  ResidentBloc({
    required this.createResidentUseCase,
    required this.loadResidentsByLocationUseCase,
    required this.deactivateResidentUseCase,
    required this.reactivateResidentUseCase,
    required this.deleteResidentUseCase,
    required this.getResidenceAccessesUseCase,
    required this.loadResidentsUseCase,
  }) : super(const ResidentInitial()) {
    on<CreateResidentEvent>(_onCreateResident);
    on<LoadResidentsEvent>(_onLoadResidents);
    on<LoadResidentsByLocationEvent>(_onLoadResidentsByLocation);
    on<DeactivateResidentEvent>(_onDeactivateResident);
    on<ReactivateResidentEvent>(_onReactivateResident);
    on<DeleteResidentEvent>(_onDeleteResident);
    on<LoadResidenceAccessesEvent>(_onLoadResidenceAccesses);
  }

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

  Future<void> _onLoadResidents(
    LoadResidentsEvent event,
    Emitter<ResidentState> emit,
  ) async {
    emit(const ResidentLoading());
    try {
      final residents = await loadResidentsUseCase.execute();
      emit(ResidentsLoaded(residents));
    } catch (e) {
      emit(ResidentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadResidentsByLocation(
    LoadResidentsByLocationEvent event,
    Emitter<ResidentState> emit,
  ) async {
    emit(const ResidentLoading());
    try {
      final residents = await loadResidentsByLocationUseCase(
        manzana: event.manzana,
        villa: event.villa,
      );
      emit(ResidentsByLocationLoaded(
        residents: residents,
        manzana: event.manzana,
        villa: event.villa,
      ));
    } catch (e) {
      emit(ResidentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeactivateResident(
    DeactivateResidentEvent event,
    Emitter<ResidentState> emit,
  ) async {
    try {
      await deactivateResidentUseCase(event.personaId, event.reason);
      emit(ResidentDeactivated(
          'Residente desactivado correctamente', event.reason));
    } catch (e) {
      emit(ResidentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onReactivateResident(
    ReactivateResidentEvent event,
    Emitter<ResidentState> emit,
  ) async {
    try {
      await reactivateResidentUseCase(event.personaId, event.reason);
      emit(ResidentReactivated(
          'Residente reactivado correctamente', event.reason));
    } catch (e) {
      emit(ResidentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeleteResident(
    DeleteResidentEvent event,
    Emitter<ResidentState> emit,
  ) async {
    try {
      await deleteResidentUseCase(event.personaId, event.motivo);
      emit(const ResidentDeleted('Residente eliminado correctamente'));
    } catch (e) {
      emit(ResidentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadResidenceAccesses(
    LoadResidenceAccessesEvent event,
    Emitter<ResidentState> emit,
  ) async {
    emit(const ResidentLoading());
    try {
      final accesses = await getResidenceAccessesUseCase(
        viviendaId: event.viviendaId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
        tipo: event.tipo,
        resultado: event.resultado,
      );
      emit(ResidenceAccessesLoaded(
        accessesData: accesses,
        viviendaId: event.viviendaId,
      ));
    } catch (e) {
      emit(ResidentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
